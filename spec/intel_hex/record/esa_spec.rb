RSpec.describe IntelHex::Record::Esa do
  describe "class methods" do
    it "has expected type metadata" do
      expect(described_class.type_id).to eq 2
      expect(described_class.type_name).to eq :esa
      expect(described_class.type_data_length).to eq 2
    end
  end

  it "can create an empty record" do
    record = IntelHex::Record.esa

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :esa
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 254
  end

  it "handles assignment of a value" do
    record = IntelHex::Record.esa
    record.value = 0x1234

    expect(record.value).to eq 0x1234
    expect(record.value_s).to eq "4660"
    expect(record.length).to eq 2
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34]
    expect(record.checksum).to eq 182
  end

  it "can create a record from a value" do
    record = IntelHex::Record.esa(0x1234)

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :esa
    expect(record.value).to eq 0x1234
    expect(record.value_s).to eq "4660"
  end

  it "formats with to_s and to_h" do
    record = IntelHex::Record.esa(0x1234)

    expect(record.to_s).to eq "#<IntelHex::Record::Esa type=esa offset=0 length=2 esa=4660>"
    expect(record.to_h).to eq({
                                type: :esa,
                                offset: 0,
                                length: 2,
                                checksum: 182,
                                esa: 0x1234,
                              })
  end

  it "generates the correct ASCII record" do
    record = IntelHex::Record.esa(0x1234)

    expect(record.to_ascii).to eq ":020000021234B6"
  end

  it "parses an ASCII record" do
    record = IntelHex::Record.parse(":020000021234B6")

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :esa
    expect(record.value).to eq 0x1234
    expect(record.length).to eq 2
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34]
    expect(record.checksum).to eq 182
    expect(record.valid?).to be true
  end

  it "validates that length must be 2" do
    bad_length_record = described_class.new(1, 0, [0x12])
    expect(bad_length_record.valid?).to be false
    expect { bad_length_record.validate }.to raise_error(IntelHex::InvalidLengthError)

    valid_record = described_class.new(2, 0, [0x12, 0x34])
    expect(valid_record.valid?).to be true
    expect(valid_record.validate).to be true
  end
end
