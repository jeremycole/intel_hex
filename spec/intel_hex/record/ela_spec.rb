RSpec.describe IntelHex::Record::Ela do
  it "can create an empty record" do
    record = IntelHex::Record.ela

    expect(record).to be_an_instance_of IntelHex::Record::Ela
    expect(record.type).to eq :ela
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 252
  end

  it "handles assignment of a value" do
    record = IntelHex::Record.ela
    record.value = 0x1234

    expect(record.value).to eq 0x1234
    expect(record.length).to eq 2
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34]
    expect(record.checksum).to eq 180
  end

  it "can create a record from a value" do
    record = IntelHex::Record.ela(0x1234)

    expect(record).to be_an_instance_of IntelHex::Record::Ela
    expect(record.type).to eq :ela
    expect(record.value).to eq 0x1234
  end

  it "generates the correct ASCII record" do
    record = IntelHex::Record.ela(0x1234)

    expect(record.to_ascii).to eq ":020000041234B4"
  end

  it "parses an ASCII record" do
    record = IntelHex::Record.parse(":020000041234B4")

    expect(record).to be_an_instance_of IntelHex::Record::Ela
    expect(record.type).to eq :ela
    expect(record.value).to eq 0x1234
    expect(record.length).to eq 2
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34]
    expect(record.checksum).to eq 180
    expect(record.valid?).to be true
  end
end
