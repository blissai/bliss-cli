# A class to handle config and instantiation of tasks
class BlissRunner
  include Gitbase
  def initialize(auto = false)
    # Load configuration File if it exists
    @conf_dir = File.expand_path('~/.bliss')
    @conf_path = "#{@conf_dir}/config.yml"
    if File.exist? @conf_path
      @config = YAML.load_file(@conf_path)
    else
      @config = {}
    end
    get_config unless auto
    @docker_runner = DockerRunner.new(@config, @config['TOP_LVL_DIR'],
                                      'blissai/collector')
    update_repositories
  end

  # Initialize state from config file or user input
  def get_config
    puts 'Configuring collector...'
    get_or_save_arg('What\'s your Bliss API Key?', 'API_KEY')
    get_or_save_arg('Which directory are your repositories located in?', 'TOP_LVL_DIR')
    get_or_save_arg('What is the name of your organization in git?', 'ORG_NAME')
    set_host
    FileUtils.mkdir_p @conf_dir
    File.open(@conf_path, 'w') { |f| f.write @config.to_yaml } # Store
    puts 'Collector configured.'.green
  end

  def choose_command
    puts 'Which command would you like to run? ((C)ollector, (S)tats, (L)inter or (Q)uit).'
    command = gets.chomp.upcase
    if command == 'C'
      puts 'Running Collector'
      @docker_runner.run('collector')
    elsif command == 'L'
      puts 'Running Linter'
      @docker_runner.run('linter')
    elsif command == 'S'
      puts 'Running Stats'
      @docker_runner.run('stats')
    else
      puts 'Not a valid option. Please choose Collector, Lint, Stats or Quit.' unless command == 'Q'
    end
    choose_command unless command.eql? 'Q'
  end

  # A function that automates the above three functions for a scheduled job
  def automate
    if configured?
      @docker_runner.run('collector')
      # Sleep to wait for workers to finish
      sleep(60)
      @docker_runner.run('linter')
      # Sleep to wait for workers to finish
      sleep(60)
      @docker_runner.run('stats')
    else
      puts 'Collector has not been configured. Cannot run auto-task.'.red
    end
  end

  def configured?
    !@config['TOP_LVL_DIR'].empty? && !@config['ORG_NAME'].empty? && !@config['API_KEY'].empty? && !@config['BLISS_HOST'].empty?
  end

  def task_sched(option)
    # Choose frequency
    if option == 1
      freq = '/SC DAILY'
    elsif option == 2
      freq = '/SC HOURLY'
    else
      freq = '/SC MINUTE /MO 10'
    end

    # Get current path
    cwd = `@powershell $pwd.path`.gsub(/\n/, '')
    task_cmd = "cd  #{cwd}\nruby blissauto.rb"

    # create batch file
    file_name = "#{cwd}\\blisstask.bat"
    File.open(file_name, 'w') { |file| file.write(task_cmd) }

    # schedule task with schtasks
    cmd = "schtasks /Create #{freq} /TN BlissCollector /TR #{file_name}"
    `#{cmd}`
  end

  def set_host
    @config['BLISS_HOST'] ||= 'https://app.founderbliss.com'
  end

  def git_dir?(dir)
    cmd = "cd #{dir} && git rev-parse"
    cmd = "#{cmd} > /dev/null 2>&1" unless Gem.win_platform?
    system(cmd)
  end

  def is_valid_arg(env, arg)
    if env.eql? 'TOP_LVL_DIR'
      if !File.directory?(arg)
        m = 'That is not a valid directory. Please enter a directory that contains your git repository folders.'
      elsif git_dir?(arg)
        m = 'That is a git directory. Please enter a directory that contains your git repository folders, not the repository folders themselves.'
      end
      return { valid: m.nil?, msg: m }
    else
      return { valid: true, msg: nil }
    end
  end

  private

  # Checks for saved argument in config file, otherwise prompts user
  def get_or_save_arg(message, env_name)
    if @config && @config[env_name]
      puts "Loading #{env_name} from config.yml...".blue
    else
      puts message.blue
      arg = gets.chomp
      arg = File.expand_path(arg) if env_name.eql? 'TOP_LVL_DIR'
      valid = is_valid_arg(env_name, arg)
      if !valid[:valid]
        get_or_save_arg(valid[:msg], env_name)
      else
        @config[env_name] = arg
      end
    end
  end

  def update_repositories
    puts 'Updating repositories to latest commit...'
    repos = Dir.glob(File.expand_path("#{@config['TOP_LVL_DIR']}/*"))
            .select { |fn| File.directory? fn }
    repos.each do |dir|
      cmd = "cd #{dir} && git pull"
      puts "\tPulling repository at #{dir}...".blue
      checkout_commit(dir, 'master')
      `#{cmd}`
    end
  end
end
