RSpec.describe [IntelHex::Record, :eof] do
  it 'can create a record' do
    record = IntelHex::Record.new(:eof)

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :eof
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 0xff
  end

  it 'can create a record' do
    record = IntelHex::Record.eof

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :eof
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 0xff
  end

  it 'generates the correct ASCII record' do
    record = IntelHex::Record.eof

    expect(record.to_ascii).to eq ':00000001FF'
  end

  it 'parses an ASCII record' do
    record = IntelHex::Record.parse(':00000001FF')

    expect(record).to be_an_instance_of IntelHex::Record
    expect(record.type).to eq :eof
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 0xff
    expect(record.valid?).to be true
  end
end
