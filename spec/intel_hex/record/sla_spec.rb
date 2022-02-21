RSpec.describe IntelHex::Record::Sla do
  it "can create an empty record" do
    record = IntelHex::Record.sla

    expect(record).to be_an_instance_of IntelHex::Record::Sla
    expect(record.type).to eq :sla
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 251
  end

  it "handles assignment of a value" do
    record = IntelHex::Record.sla
    record.sla = 0x12345678

    expect(record.sla).to eq 0x12345678
    expect(record.length).to eq 4
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34, 0x56, 0x78]
    expect(record.checksum).to eq 227
  end

  it "can create a record from a value" do
    record = IntelHex::Record.sla(0x12345678)

    expect(record).to be_an_instance_of IntelHex::Record::Sla
    expect(record.type).to eq :sla
    expect(record.sla).to eq 0x12345678
  end

  it "generates the correct ASCII record" do
    record = IntelHex::Record.sla(0x12345678)

    expect(record.to_ascii).to eq ":0400000512345678E3"
  end

  it "parses an ASCII record" do
    record = IntelHex::Record.parse(":0400000512345678E3")

    expect(record).to be_an_instance_of IntelHex::Record::Sla
    expect(record.type).to eq :sla
    expect(record.sla).to eq 0x12345678
    expect(record.length).to eq 4
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34, 0x56, 0x78]
    expect(record.checksum).to eq 227
    expect(record.valid?).to be true
  end
end
