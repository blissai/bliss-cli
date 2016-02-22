class LocalRunner
  def initialize(args, cmd)
    @docker = DockerCmd.new(args, 'blissai/collector', cmd)
  end

  def execute
    @docker.run
  end
end
