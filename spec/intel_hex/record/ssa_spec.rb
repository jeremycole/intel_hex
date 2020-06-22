RSpec.describe [IntelHex::Record, :ssa] do
  it 'can create an empty record' do
    record = IntelHex::Record.new(:ssa)

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :ssa
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 253
  end

  it 'handles assignment of a value' do
    record = IntelHex::Record.new(:ssa)
    record.ssa = 0x12345678

    expect(record.ssa).to eq 0x12345678
    expect(record.length).to eq 4
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34, 0x56, 0x78]
    expect(record.checksum).to eq 229
  end

  it 'can create a record from a value' do
    record = IntelHex::Record.ssa(0x12345678)

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :ssa
    expect(record.ssa).to eq 0x12345678
  end

  it 'generates the correct ASCII record' do
    record = IntelHex::Record.ssa(0x12345678)

    expect(record.to_ascii).to eq ':0400000312345678E5'
  end

  it 'parses an ASCII record' do
    record = IntelHex::Record.parse(':0400000312345678E5')

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :ssa
    expect(record.ssa).to eq 0x12345678
    expect(record.length).to eq 4
    expect(record.offset).to eq 0
    expect(record.data).to eq [0x12, 0x34, 0x56, 0x78]
    expect(record.checksum).to eq 229
    expect(record.valid?).to be true
  end
end
