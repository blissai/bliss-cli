require_relative '../spec_helper'
RSpec.describe DockerLocal do
  before(:all) do
    @mountable_args = [
      'dir=/test/directory',
      'linter_config_path=/test/linter/path.txt',
      'output_file=/test/output/filepath'
    ]
    @env_args = [
      'test_env=testenv',
      'test_env_two=testenvtwo'
    ]
    @all_args = @mountable_args + @env_args
    @testdir = '/test/mytestrepodir'
    @docker_runner = DockerLocal.new(@all_args, 'bliss-command', 'test/image')
  end

  it 'should have the correct command' do
    expected = 'docker run' \
    '  -v /test/directory:/repository -v /test/linter/path.txt:/linter.yml -v /test/output/filepath:/result.txt' \
    ' --rm -t test/image ruby /root/collector/bin/bliss-command test_env=testenv test_env_two=testenvtwo'
    expect(@docker_runner.docker_start_cmd).to eq(expected)
  end
end
