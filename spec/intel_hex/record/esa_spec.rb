RSpec.describe [IntelHex::Record, :esa] do
  it "can create an empty record" do
    record = IntelHex::Record.new(:esa)

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :esa
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 254
  end

  it "handles assignment of a value" do
    record = IntelHex::Record.new(:esa)
    record.esa = 0x1234

    expect(record.esa).to eq 0x1234
    expect(record.length).to eq 2
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34]
    expect(record.checksum).to eq 182
  end

  it "can create a record from a value" do
    record = IntelHex::Record.esa(0x1234)

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :esa
    expect(record.esa).to eq 0x1234
  end

  it "generates the correct ASCII record" do
    record = IntelHex::Record.esa(0x1234)

    expect(record.to_ascii).to eq ":020000021234B6"
  end

  it "parses an ASCII record" do
    record = IntelHex::Record.parse(":020000021234B6")

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :esa
    expect(record.esa).to eq 0x1234
    expect(record.length).to eq 2
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34]
    expect(record.checksum).to eq 182
    expect(record.valid?).to be true
  end
end