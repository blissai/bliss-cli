require_relative 'spec_helper'
RSpec.describe ProjectAnalyzer do
  before(:all) do

  end

  it 'should be too big' do
    @pa = ProjectAnalyzer.new(Dir.pwd, 5)
    expect(@pa.too_big?).to eq(true)
  end

  it 'should not be too big' do
    # TODO Don't hardcode a value, 100m is fine for now
    @pa = ProjectAnalyzer.new(FileUtils.pwd, 100_000_000)
    expect(@pa.too_big?).to eq(false)
  end
end
