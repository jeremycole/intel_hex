RSpec.describe IntelHex::Record::Eof do
  describe "class methods" do
    it "has expected type metadata" do
      expect(described_class.type_id).to eq 1
      expect(described_class.type_name).to eq :eof
      expect(described_class.type_data_length).to eq 0
    end
  end

  it "can create a record" do
    record = IntelHex::Record.eof

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :eof
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 0xff
    expect(record.value).to be_nil
    expect(record.value_s).to eq ""
    expect(record.valid?).to be true
  end

  it "formats with to_s and to_h" do
    record = IntelHex::Record.eof

    expect(record.to_s).to eq "#<IntelHex::Record::Eof type=eof offset=0 length=0 eof=>"
    expect(record.to_h).to eq({
                                type: :eof,
                                offset: 0,
                                length: 0,
                                checksum: 0xff,
                                eof: nil,
                              })
  end

  it "generates the correct ASCII record" do
    record = IntelHex::Record.eof

    expect(record.to_ascii).to eq ":00000001FF"
  end

  it "parses an ASCII record" do
    record = IntelHex::Record.parse(":00000001FF")

    expect(record).to be_an_instance_of described_class
    expect(record.type).to eq :eof
    expect(record.length).to eq 0
    expect(record.offset).to eq 0
    expect(record.data).to eq []
    expect(record.checksum).to eq 0xff
    expect(record.valid?).to be true
  end

  it "validates that length must be 0" do
    bad_length_record = described_class.new(1, 0, [0])
    expect(bad_length_record.valid?).to be false
    expect { bad_length_record.validate }.to raise_error(IntelHex::InvalidLengthError)
  end
end
