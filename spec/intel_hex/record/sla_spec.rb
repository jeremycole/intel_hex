RSpec.describe IntelHex::Record::Sla do
  describe "class methods" do
    it "has expected type metadata" do
      expect(described_class.type_id).to eq 5
      expect(described_class.type_name).to eq :sla
      expect(described_class.type_data_length).to eq 4
    end
  end

  it "can create an empty record" do
    record = IntelHex::Record.sla

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :sla
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 251
  end

  it "handles assignment of a value" do
    record = IntelHex::Record.sla
    record.value = 0x12345678

    expect(record.value).to eq 0x12345678
    expect(record.value_s).to eq "305419896"
    expect(record.length).to eq 4
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34, 0x56, 0x78]
    expect(record.checksum).to eq 227
  end

  it "can create a record from a value" do
    record = IntelHex::Record.sla(0x12345678)

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :sla
    expect(record.value).to eq 0x12345678
    expect(record.value_s).to eq "305419896"
  end

  it "formats with to_s and to_h" do
    record = IntelHex::Record.sla(0x12345678)

    expect(record.to_s).to eq "#<IntelHex::Record::Sla type=sla offset=0 length=4 sla=305419896>"
    expect(record.to_h).to eq({
                                type: :sla,
                                offset: 0,
                                length: 4,
                                checksum: 227,
                                sla: 0x12345678,
                              })
  end

  it "generates the correct ASCII record" do
    record = IntelHex::Record.sla(0x12345678)

    expect(record.to_ascii).to eq ":0400000512345678E3"
  end

  it "parses an ASCII record" do
    record = IntelHex::Record.parse(":0400000512345678E3")

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :sla
    expect(record.value).to eq 0x12345678
    expect(record.length).to eq 4
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34, 0x56, 0x78]
    expect(record.checksum).to eq 227
    expect(record.valid?).to be true
  end

  it "validates that length must be 4" do
    bad_length_record = described_class.new(2, 0, [0x12, 0x34])
    expect(bad_length_record.valid?).to be false
    expect { bad_length_record.validate }.to raise_error(IntelHex::InvalidLengthError)

    valid_record = described_class.new(4, 0, [0x12, 0x34, 0x56, 0x78])
    expect(valid_record.valid?).to be true
    expect(valid_record.validate).to be true
  end
end
