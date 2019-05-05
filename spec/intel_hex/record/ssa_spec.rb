RSpec.describe [IntelHex::Record, :ssa] do
  it "can create an empty record" do
    record = IntelHex::Record.new(:ssa)

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :ssa
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 253
  end

  it "handles assignment of a value" do
    record = IntelHex::Record.new(:ssa)
    record.ssa = 0x1234

    expect(record.ssa).to eq 0x1234
    expect(record.length).to eq 2
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34]
    expect(record.checksum).to eq 181
  end

  it "can create a record from a value" do
    record = IntelHex::Record.ssa(0x1234)

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :ssa
    expect(record.ssa).to eq 0x1234
  end

  it "generates the correct ASCII record" do
    record = IntelHex::Record.ssa(0x1234)

    expect(record.to_ascii).to eq ":020000031234B5"
  end

  it "parses an ASCII record" do
    record = IntelHex::Record.parse(":020000031234B5")

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :ssa
    expect(record.ssa).to eq 0x1234
    expect(record.length).to eq 2
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34]
    expect(record.checksum).to eq 181
    expect(record.valid?).to be true
  end
end