RSpec.describe IntelHex::Record do
  it "has type_by_id" do
    expect(described_class.type_by_id).to be_an_instance_of(Hash)
    expect(described_class.type_by_id.to_h { |*x| x.map(&:class) }).to eq({ Integer => Class })
  end

  it "has type_by_name" do
    expect(described_class.type_by_name).to be_an_instance_of(Hash)
    expect(described_class.type_by_name.to_h { |*x| x.map(&:class) }).to eq({ Symbol => Class })
  end
end
