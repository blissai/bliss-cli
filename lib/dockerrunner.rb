# Class to encapsulate docker commands
class DockerRunner
  def initialize(env_vars, repos_dir, image_name)
    @env_vars = env_vars
    @env_vars['TOP_LVL_DIR'] = '/repositories'
    @repos_dir = repos_dir
    @image_name = image_name
    pull_image
  end

  def run(command)
    system docker_start_cmd(command)
    remove_stopped
  end

  def docker_start_cmd(command)
    docker_cmd = "docker run -i -v #{@repos_dir}:/repositories"
    @env_vars.each do |k, v|
      docker_cmd += " -e \"#{k}=#{v}\""
    end
    collector_cmds = "jruby /root/collector/blisscollector.rb #{command}"
    "#{docker_cmd} --rm -t #{@image_name} #{collector_cmds}"
  end

  def build_image
    puts 'Building docker image...'
    build_cmd = "docker build -t #{@image_name} ."
    result = []
    Open3.popen3(build_cmd)do |_stdin, stdout, stderr, wait_thr|
      result << stderr.read
      result << stdout.read
      wait_thr.value
    end
    return if result.join('') !~ /Cannot connect to the Docker daemon/
    puts 'Docker is not running. Please ensure docker is started.'.red
    exit
  end

  def pull_image
    puts 'Pulling docker image...'
    pull_cmd = "docker pull #{@image_name}"
    pull_success = system pull_cmd
    return if pull_success
    puts 'Docker is not running or is not configured correctly.'.red
    puts 'You may need to start the docker daemon or restart your docker Virtual Machine.'.red
    puts 'Also ensure you have an internet connection.'.red
    puts "Docker Machine (OSX/Windows) users can try:\ndocker-machine create --driver \"generic\" default default # This may already be created. If so, just carry on.\neval \"$(docker-machine env default)\"".red
    puts "Unix users can try:\nsudo service docker start".red
    exit
  end

  def image_exists?
    `docker images`.include? @image_name
  end

  def remove_stopped
    stopped_containers = `docker ps -a -q`.split("\n")
    stopped_containers.each do |c|
      puts `docker rm #{c}`
    end
  end
end
