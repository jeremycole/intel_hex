RSpec.describe IntelHex::Record::Data do
  it "can create an empty record" do
    record = IntelHex::Record.data

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :data
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 0
  end

  it "handles assignment of an array" do
    record = IntelHex::Record.data
    record.data = [1, 2, 3]

    expect(record.length).to eq 3
    expect(record.data).to eq [1, 2, 3]
    expect(record.checksum).to eq 247
  end

  it "can create a record from an array" do
    record = IntelHex::Record.data([1, 2, 3])

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :data
    expect(record.length).to eq 3
    expect(record.offset).to eq 0
    expect(record.data).to eq [1, 2, 3]
    expect(record.checksum).to eq 247
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
end
