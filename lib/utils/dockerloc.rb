class DockerLoc < DockerRunner
  attr_accessor :directory

  def initialize(directory)
    @directory = directory
  end

  def docker_start_cmd
    bash_cmd = "find /repository -type f \\( #{supported_files} \\) -exec cat -- {} + | wc -l"
    "docker run --rm -v #{@directory}:/repository -t blissai/collector #{bash_cmd}"
  end

  def run
    loc
  end

  private

  def loc
    result = []
    Open3.popen3(docker_start_cmd) do |_stdin, stdout, stderr, wait_thr|
      result << stdout.read
      result << stderr.read
    end
    result = result.join('')
    return result.strip.to_i if result !~ /Cannot connect to the Docker daemon/
    puts 'Docker is not running. Please ensure docker is started.'.red
    exit
  end

  # Supported extensions to search for
  def supported_files
    langs = %w(sh rb py go m mm h cpp css js class java php bat ps1 swift f pm pl)
    '-name "' + langs.join('" -o -name "*.') + '"'
  end
end
