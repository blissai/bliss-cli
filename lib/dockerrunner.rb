# Class to encapsulate docker commands
class DockerRunner
  def initialize(env_vars, repos_dir, image_name)
    @env_vars = env_vars
    @env_vars['TOP_LVL_DIR'] = '/repositories'
    @repos_dir = repos_dir
    @image_name = image_name
    build_image
  end

  def run(command)
    puts `#{docker_start_cmd(command)}`
    remove_stopped
  end

  def docker_start_cmd(command)
    docker_cmd = "docker run -i -v #{@repos_dir}:/repositories"
    @env_vars.each do |k, v|
      cmd += " -e \"#{k}=#{v}\""
    end
    collector_cmds = "jruby /root/collector/blisscollector.rb #{command}"
    "#{docker_cmd} --rm -t #{@image_name} #{collector_cmds}"
  end

  def build_image
    puts "Building docker image..."
    puts `docker build -t #{@image_name} .`
  end

  def image_exists?
    `docker images`.include? @image_name
  end

  def remove_stopped
    stopped_containers = `docker ps -a -q`.split('\n').join(' ')
    puts `docker rm #{stopped_containers}` unless stopped_containers.empty?
  end
end
