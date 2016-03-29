class DockerLocal < DockerRunner
  def initialize(args, cmd, image_name = 'blissai/collector')
    sort_args(args)
    @image_name = image_name
    @cmd = cmd
    # pull_image
  end

  def docker_start_cmd
    docker_cmd = 'docker run'
    mount_cmd = ''
    @files_to_mount.each do |k, v|
      mount_cmd += " -v #{k}:#{v}"
    end
    collector_cmds = "ruby /root/collector/bin/#{@cmd} #{@args.join(' ')}"
    "#{docker_cmd} #{mount_cmd} --rm -t #{@image_name} #{collector_cmds}"
  end

  # Seperate files to mount from standard args
  def sort_args(args)
    @files_to_mount = {}
    @args = []
    args.each do |a|
      k, v = a.split('=')
      if mountable?(k)
        @files_to_mount[format_path(v)] = mounts[k]
      else
        @args.push(a)
      end
    end
  end

  # Mountable files
  def mounts
    {
      'dir' => '/repository',
      'linter_config_path' => '/linter.yml',
      'output_file' => '/result.txt'
    }
  end

  def mountable?(k)
    mounts.key?(k)
  end
end
