RSpec.describe "blink.hex" do
  RECORDS = [
    {type: :data, offset: 0x0000, length: 0x10, checksum: 0x82},
    {type: :data, offset: 0x0010, length: 0x10, checksum: 0x68},
    {type: :data, offset: 0x0020, length: 0x10, checksum: 0x58},
    {type: :data, offset: 0x0030, length: 0x10, checksum: 0x48},
    {type: :data, offset: 0x0040, length: 0x10, checksum: 0x38},
    {type: :data, offset: 0x0050, length: 0x10, checksum: 0x28},
    {type: :data, offset: 0x0060, length: 0x10, checksum: 0x4c},
    {type: :data, offset: 0x0070, length: 0x10, checksum: 0xdf},
    {type: :data, offset: 0x0080, length: 0x10, checksum: 0x8c},
    {type: :data, offset: 0x0090, length: 0x10, checksum: 0x63},
    {type: :data, offset: 0x00a0, length: 0x10, checksum: 0x14},
    {type: :eof,  offset: 0x0000, length: 0x00, checksum: 0xff}
  ].freeze

  it "parses blink.hex correctly" do
    intel_hex_file = IntelHex::FileReader.new(File.join($spec_data_dir, "blink.hex"))
    records = intel_hex_file.each_record.to_a

    expect(records.size).to eq RECORDS.size
    RECORDS.each_with_index do |expected_record, i|
      expect(records[i].type).to      eq expected_record[:type]
      expect(records[i].offset).to    eq expected_record[:offset]
      expect(records[i].length).to    eq expected_record[:length]
      expect(records[i].checksum).to  eq expected_record[:checksum]
      expect(records[i].valid?).to    eq true
      expect(records[i].to_ascii).to  eq records[i].line
    end
  end
end