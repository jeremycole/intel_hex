require "tempfile"

RSpec.describe IntelHex::FileReader do
  let(:tempfile) { Tempfile.new(["test", ".hex"]) }

  after do
    tempfile.close
    tempfile.unlink
  end

  describe "#initialize" do
    it "initializes with default address base and mask" do
      reader = described_class.new(tempfile.path)

      expect(reader.address_base).to eq 0
      expect(reader.address_mask).to eq 0xffff
    end
  end

  describe "#each_record" do
    it "returns an Enumerator when no block is given" do
      reader = described_class.new(tempfile.path)

      expect(reader.each_record).to be_an_instance_of Enumerator
    end

    it "yields each parsed record in file order" do
      tempfile.write(":020000041234B4\n:03001000010203E7\n:00000001FF\n")
      tempfile.flush

      reader = described_class.new(tempfile.path)
      records = []
      reader.each_record { |record| records << record }

      expect(records.size).to eq 3
      expect(records[0]).to be_an_instance_of IntelHex::Record::Ela
      expect(records[0].value).to eq 0x1234
      expect(records[1]).to be_an_instance_of IntelHex::Record::Data
      expect(records[1].offset).to eq 0x0010
      expect(records[1].data).to eq [1, 2, 3]
      expect(records[2]).to be_an_instance_of IntelHex::Record::Eof
    end
  end

  describe "#each_byte_with_address" do
    it "returns an Enumerator when no block is given" do
      reader = described_class.new(tempfile.path)

      expect(reader.each_byte_with_address).to be_an_instance_of Enumerator
    end

    it "iterates through bytes with default 16-bit addressing" do
      tempfile.write(":02010000AABB98\n:00000001FF\n")
      tempfile.flush

      reader = described_class.new(tempfile.path)
      bytes = reader.each_byte_with_address.to_a

      expect(bytes).to eq [
        [0xaa, 0x0100],
        [0xbb, 0x0101],
      ]
    end

    it "calculates 20-bit addresses after an Extended Segment Address (ESA) record" do
      # ESA record with value 0x1200 sets base = 0x12000, mask = 0xfffff
      # Data record at offset 0x0034 with bytes [0x10, 0x20] -> addresses 0x12034, 0x12035
      tempfile.write(":020000021200EA\n:0200340010209A\n:00000001FF\n")
      tempfile.flush

      reader = described_class.new(tempfile.path)
      bytes = reader.each_byte_with_address.to_a

      expect(reader.address_base).to eq 0x12000
      expect(reader.address_mask).to eq 0xfffff
      expect(bytes).to eq [
        [0x10, 0x12034],
        [0x20, 0x12035],
      ]
    end

    it "calculates 32-bit addresses after an Extended Linear Address (ELA) record" do
      # ELA record with value 0x1234 sets base = 0x12340000, mask = 0xffffffff
      # Data record at offset 0x0050 with bytes [0x30, 0x40] -> addresses 0x12340050, 0x12340051
      tempfile.write(":020000041234B4\n:0200500030403E\n:00000001FF\n")
      tempfile.flush

      reader = described_class.new(tempfile.path)
      bytes = reader.each_byte_with_address.to_a

      expect(reader.address_base).to eq 0x12340000
      expect(reader.address_mask).to eq 0xffffffff
      expect(bytes).to eq [
        [0x30, 0x12340050],
        [0x40, 0x12340051],
      ]
    end

    it "ignores non-data records such as SSA, SLA, and EOF without yielding bytes" do
      # SSA (:0400000312345678E5), SLA (:0400000512345678E3), EOF (:00000001FF)
      tempfile.write(":0400000312345678E5\n:0400000512345678E3\n:00000001FF\n")
      tempfile.flush

      reader = described_class.new(tempfile.path)
      bytes = reader.each_byte_with_address.to_a

      expect(bytes).to be_empty
    end

    it "handles switching between different address bases in a single file" do
      # First segment 0x1000 -> base 0x10000
      # Second segment 0x2000 -> base 0x20000
      lines = [
        ":020000021000EC",
        ":01000500AA50",
        ":020000022000DC",
        ":01000A00BB3A",
        ":00000001FF",
        "",
      ].join("\n")
      tempfile.write(lines)
      tempfile.flush

      reader = described_class.new(tempfile.path)
      bytes = reader.each_byte_with_address.to_a

      expect(bytes).to eq [
        [0xaa, 0x10005],
        [0xbb, 0x2000a],
      ]
    end
  end
end
