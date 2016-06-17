require_relative '../spec_helper'
RSpec.describe ProjectAnalyzer do
  before(:all) do
    @testdir = File.expand_path('~/testrepo')
    `git clone https://github.com/mikesive/Slicki.git #{@testdir}`
    allow_any_instance_of(DockerLoc).to receive(:run).and_return(69)
  end

  it 'should be too big' do
    @pa = ProjectAnalyzer.new(@testdir, 3)
    expect(@pa.too_big?).to eq(true)
  end

  it 'should not be too big' do
    @pa = ProjectAnalyzer.new(@testdir, 100_000_000)
    expect(@pa.too_big?).to eq(false)
  end
end
