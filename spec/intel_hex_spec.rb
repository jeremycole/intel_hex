RSpec.describe IntelHex do
  it "is a Module" do
    expect(described_class).to be_an_instance_of Module
  end

  it "has a valid VERSION constant" do
    expect(IntelHex::VERSION).to be_a(String)
    expect(IntelHex::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
