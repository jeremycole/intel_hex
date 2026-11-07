RSpec.describe IntelHex::Record::Data do
  describe "class methods" do
    it "has expected type metadata" do
      expect(described_class.type_id).to eq 0
      expect(described_class.type_name).to eq :data
      expect(described_class.type_data_length).to eq(1..255)
    end
  end

  it "can create an empty record" do
    record = IntelHex::Record.data

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :data
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 0
    expect(record.value).to eq []
  end

  it "handles assignment of an array" do
    record = IntelHex::Record.data
    record.data = [1, 2, 3]

    expect(record.length).to eq 3
    expect(record.data).to eq [1, 2, 3]
    expect(record.value).to eq [1, 2, 3]
    expect(record.value_s).to eq "[01 02 03]"
    expect(record.checksum).to eq 247
  end

  it "can create a record from an array" do
    record = IntelHex::Record.data([1, 2, 3])

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :data
    expect(record.length).to eq 3
    expect(record.offset).to eq 0
    expect(record.data).to eq [1, 2, 3]
    expect(record.value).to eq [1, 2, 3]
    expect(record.value_s).to eq "[01 02 03]"
    expect(record.checksum).to eq 247
  end

  it "formats with to_s and to_h" do
    record = IntelHex::Record.data([1, 2, 3])

    expect(record.to_s).to eq "#<IntelHex::Record::Data type=data offset=0 length=3 data=[01 02 03]>"
    expect(record.to_h).to eq({
                                type: :data,
                                offset: 0,
                                length: 3,
                                checksum: 247,
                                data: [1, 2, 3],
                              })
  end

  it "generates the correct ASCII record" do
    record = IntelHex::Record.data([1, 2, 3])

    expect(record.to_ascii).to eq ":03000000010203F7"
  end

  it "parses an ASCII record" do
    record = IntelHex::Record.parse(":03000000010203F7")

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :data
    expect(record.length).to eq 3
    expect(record.offset).to eq 0
    expect(record.data).to eq [1, 2, 3]
    expect(record.checksum).to eq 247
    expect(record.valid?).to be true
  end

  it "validates that length is within 1..255" do
    empty_record = described_class.new(0, 0, [])
    expect(empty_record.valid?).to be false
    expect { empty_record.validate }.to raise_error(IntelHex::InvalidLengthError)

    valid_record = described_class.new(2, 0, [0x10, 0x20])
    expect(valid_record.valid?).to be true
    expect(valid_record.validate).to be true
  end
end
