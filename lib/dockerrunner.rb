# Class to encapsulate docker commands
class DockerRunner
  def initialize(env_vars, repos_dir, image_name = 'blissai/collector:latest', pull_latest = true)
    @env_vars = env_vars
    @env_vars['TOP_LVL_DIR'] = '/repositories'
    @repos_dir = format_path(repos_dir)
    @image_name = image_name
    @daemonize = false
    pull_image if pull_latest
  end

  def run(daemonfile = nil)
    command = docker_start_cmd(daemonfile)
    puts 'Running docker command...'
    system command
    unless daemonfile
      # Removed stopped containers unless rm flag is set in docker command
      puts 'Docker finished.'
      remove_stopped unless command.include?(' --rm ')
    end
  end

  def docker_start_cmd(daemonfile = nil)
    base = 'docker run'
    base += ' -i' unless daemonfile
    docker_cmd = "#{base} -v #{@repos_dir}:/repositories"
    docker_cmd += " -v #{daemonfile}:/pstatus -e daemonized=true" if daemonfile
    @env_vars.each do |k, v|
      docker_cmd += " -e \"#{k}=#{v}\""
    end
    collector_cmds = 'ruby /root/collector/blisscollector.rb'
    rm = daemonfile.nil? ? ' --rm ' : ' '
    "#{docker_cmd}#{rm}-t #{@image_name} #{collector_cmds}"
  end

  def build_image
    puts 'Building docker image...'
    build_cmd = "docker build -t #{@image_name} ."
    result = []
    Open3.popen3(build_cmd) do |_stdin, stdout, stderr, wait_thr|
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
    puts "Docker Machine (OSX/Windows) users can try:\ndocker-machine create --driver virtualbox default # This may already be created. If so, just carry on.\neval \"$(docker-machine env default)\"".red
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

  def format_path(path)
    return nil if path.nil?
    return path unless Gem.win_platform?
    drive = path[/^[a-zA-Z]*:/]
    drive = drive.downcase.sub(':', '')
    path.sub(/^[a-zA-Z]*:/, "/#{drive}")
  end
end
