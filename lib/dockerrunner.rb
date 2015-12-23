# Class to encapsulate docker commands
class DockerRunner
  def initialize(env_vars, repos_dir, image_name, command)
    @env_vars = env_vars
    @repos_dir = repos_dir
    @image_name = image_name
    @command = command
    build_image unless image_exists?
  end

  def run
    `#{docker_start_cmd}`
  end

  def docker_start_cmd
    cmd = "-t #{@image_name} -v #{@repos_dir}:/repositories"
    @env_vars.each do |k, v|
      cmd += " -e \"#{k}=#{v}\""
    end
    "#{cmd} --rm #{@command}"
  end

  def build_image
    `docker build -t #{@image_name} .`
  end

  def image_exists?
    `docker images`.include? @image_name
  end

  def self.remove_stopped
    `docker rm $(docker ps -a -q)`
  end
end
