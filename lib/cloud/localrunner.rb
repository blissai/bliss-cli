class LocalRunner
  def initialize(args, cmd)
    @docker_runner = DockerLocal.new(args, cmd)
  end

  def execute
    @docker_runner.run
  end
end
