RSpec.describe IntelHex::Record do
  describe ".type_by_id and .type_by_name" do
    it "has type_by_id containing all built-in record types" do
      expect(described_class.type_by_id).to be_an_instance_of(Hash)
      expect(described_class.type_by_id.keys).to contain_exactly(0, 1, 2, 3, 4, 5)
      expect(described_class.type_by_id[0]).to eq IntelHex::Record::Data
      expect(described_class.type_by_id[1]).to eq IntelHex::Record::Eof
      expect(described_class.type_by_id[2]).to eq IntelHex::Record::Esa
      expect(described_class.type_by_id[3]).to eq IntelHex::Record::Ssa
      expect(described_class.type_by_id[4]).to eq IntelHex::Record::Ela
      expect(described_class.type_by_id[5]).to eq IntelHex::Record::Sla
    end

    it "has type_by_name containing all built-in record types" do
      expect(described_class.type_by_name).to be_an_instance_of(Hash)
      expect(described_class.type_by_name.keys).to contain_exactly(:data, :eof, :esa, :ssa, :ela, :sla)
      expect(described_class.type_by_name[:data]).to eq IntelHex::Record::Data
      expect(described_class.type_by_name[:eof]).to eq IntelHex::Record::Eof
      expect(described_class.type_by_name[:esa]).to eq IntelHex::Record::Esa
      expect(described_class.type_by_name[:ssa]).to eq IntelHex::Record::Ssa
      expect(described_class.type_by_name[:ela]).to eq IntelHex::Record::Ela
      expect(described_class.type_by_name[:sla]).to eq IntelHex::Record::Sla
    end
  end

  describe ".register_type" do
    it "raises an error if type_name is not a symbol" do
      bad_type = Class.new(described_class) do
        def self.type_id
          99
        end

        def self.type_name
          "bad_type"
        end

        def self.type_data_length
          0
        end
      end

      expect do
        described_class.register_type(bad_type)
      end.to raise_error(RuntimeError, "Type name bad_type is not a symbol")
    end

    it "raises an error if type_name is already defined" do
      duplicate_type = Class.new(described_class) do
        def self.type_id
          98
        end

        def self.type_name
          :data
        end

        def self.type_data_length
          0
        end
      end

      expect do
        described_class.register_type(duplicate_type)
      end.to raise_error(RuntimeError, "Type name data redefined")
    end

    it "raises an error if type_id is already defined" do
      duplicate_type = Class.new(described_class) do
        def self.type_id
          0
        end

        def self.type_name
          :custom_data
        end

        def self.type_data_length
          0
        end
      end

      expect do
        described_class.register_type(duplicate_type)
      end.to raise_error(RuntimeError, "Type id 0 redefined")
    end
  end

  describe ".parse" do
    it "parses a valid Intel HEX record and retains the original line" do
      record = described_class.parse(":03000000010203F7")

      expect(record).to be_an_instance_of IntelHex::Record::Data
      expect(record.length).to eq 3
      expect(record.offset).to eq 0
      expect(record.data).to eq [1, 2, 3]
      expect(record.checksum).to eq 0xf7
      expect(record.line).to eq ":03000000010203F7"
      expect(record.valid?).to be true
    end

    it "raises MisformattedFileError if line does not start with colon" do
      expect do
        described_class.parse("03000000010203F7")
      end.to raise_error(IntelHex::MisformattedFileError, "Expected ':' at start of line")
    end

    it "raises MisformattedFileError if line is too short" do
      expect do
        described_class.parse(":0000")
      end.to raise_error(IntelHex::MisformattedFileError, "Line length incorrect")
    end

    it "raises InvalidTypeError if type_id is unknown" do
      expect do
        described_class.parse(":0000009967")
      end.to raise_error(IntelHex::InvalidTypeError, "Unknown type 153")
    end

    it "raises InvalidChecksumError if checksum is incorrect during parsing" do
      expect do
        described_class.parse(":0300000001020300")
      end.to raise_error(IntelHex::InvalidChecksumError)
    end
  end

  describe "Record base instance methods" do
    let(:record) { described_class.data([1, 2, 3]) }

    it "provides type metadata and aliases" do
      expect(record.type_id).to eq 0
      expect(record.type_name).to eq :data
      expect(record.type).to eq :data
      expect(record.type_data_length).to eq(1..255)
    end

    it "updates length and recalculates checksum when data is modified" do
      record.data = [4, 5]

      expect(record.length).to eq 2
      expect(record.data).to eq [4, 5]
      expect(record.checksum).to eq record.calculate_checksum
    end

    it "raises InvalidLengthError when assigned data exceeds 255 bytes" do
      expect do
        record.data = Array.new(256, 0)
      end.to raise_error(IntelHex::InvalidLengthError, "Data length 256 too large")
    end

    it "formats to string with to_s" do
      expect(record.to_s).to eq "#<IntelHex::Record::Data type=data offset=0 length=3 data=[01 02 03]>"
    end

    it "formats to hash with to_h" do
      expect(record.to_h).to eq({
                                  type: :data,
                                  offset: 0,
                                  length: 3,
                                  checksum: 247,
                                  data: [1, 2, 3],
                                })
    end

    it "generates ASCII hex representation with to_ascii" do
      expect(record.to_ascii).to eq ":03000000010203F7"
    end

    describe "#each_byte_with_address" do
      it "returns an Enumerator when no block is given" do
        expect(record.each_byte_with_address).to be_an_instance_of Enumerator
      end

      it "yields each byte with offset + index" do
        rec = IntelHex::Record::Data.new(3, 0x1000, [0xaa, 0xbb, 0xcc])
        yielded = []
        rec.each_byte_with_address { |b, addr| yielded << [b, addr] }

        expect(yielded).to eq [
          [0xaa, 0x1000],
          [0xbb, 0x1001],
          [0xcc, 0x1002],
        ]
      end
    end

    describe "validation" do
      it "returns true on valid? for a valid record" do
        expect(record.valid?).to be true
      end

      it "returns false on valid? when any validation error occurs" do
        invalid_record = IntelHex::Record::Data.new(3, 0, [1, 2, 3], 999)
        expect(invalid_record.valid?).to be false
      end

      it "raises InvalidOffsetError if offset is negative" do
        bad_offset_record = IntelHex::Record::Data.new(3, -1, [1, 2, 3])
        expect do
          bad_offset_record.validate_offset
        end.to raise_error(IntelHex::InvalidOffsetError, "Offset -1 is negative")
      end

      it "raises InvalidOffsetError if offset is too large" do
        bad_offset_record = IntelHex::Record::Data.new(3, 65_536, [1, 2, 3])
        expect do
          bad_offset_record.validate_offset
        end.to raise_error(IntelHex::InvalidOffsetError, "Offset 65536 is too large")
      end

      it "raises InvalidLengthError if length does not match type_data_length" do
        bad_length_record = IntelHex::Record::Data.new(0, 0, [])
        expect do
          bad_length_record.validate_length
        end.to raise_error(IntelHex::InvalidLengthError, "Length for type data must be 1..255; 0 given")
      end

      it "raises InvalidDataError if data size does not match length" do
        bad_data_record = IntelHex::Record::Data.new(3, 0, [1, 2])
        expect do
          bad_data_record.validate_data
        end.to raise_error(IntelHex::InvalidDataError, "Data length 2 does not match length 3")
      end

      it "raises InvalidChecksumError if checksum does not match calculated checksum" do
        bad_checksum_record = IntelHex::Record::Data.new(3, 0, [1, 2, 3], 0)
        expect do
          bad_checksum_record.validate_checksum
        end.to raise_error(IntelHex::InvalidChecksumError, /Checksum value 0 does not match expected checksum 247/)
      end
    end
  end
end
