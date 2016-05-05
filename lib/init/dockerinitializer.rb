class DockerInitializer < DockerRunner
  attr_accessor :args
  def initialize(git_dir, env_vars, image_name = 'blissai/collector:latest', pull_latest = true)
    @git_dir = format_path(git_dir)
    @env_vars = env_vars
    @args = []
    @image_name = image_name
    @cmd = 'bliss-init'
    pull_image if pull_latest
  end

  def docker_start_cmd
    docker_cmd = 'docker run'
    mount_cmd = " -v #{@git_dir}:/repository"
    @env_vars.each do |k, v|
      docker_cmd += " -e \"#{k}=#{v}\""
    end
    collector_cmds = "ruby /root/collector/bin/#{@cmd} #{@args.join(' ')}"
    "#{docker_cmd} #{mount_cmd} --rm -t #{@image_name} #{collector_cmds}"
  end
end
