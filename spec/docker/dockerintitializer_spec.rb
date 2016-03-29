require_relative '../spec_helper'
RSpec.describe DockerInitializer do
  before(:all) do
    env_vars = {
      'test_env' => 'testenv',
      'test_env_two' => 'testenvtwo'
    }

    testargs = ['blah=blah', 'blahblah=blahblah']
    @testdir = '/test/mytestrepodir'
    @docker_runner = DockerInitializer.new(@testdir, env_vars, 'test/image', false)
    @docker_runner.args = testargs
  end

  it 'should have the correct command' do
    expected = 'docker run -e "test_env=testenv" -e "test_env_two=testenvtwo"' \
    "  -v #{@testdir}:/repository" \
    ' --rm -t test/image ruby /root/collector/bin/bliss-init blah=blah blahblah=blahblah'
    expect(@docker_runner.docker_start_cmd).to eq(expected)
  end
end
