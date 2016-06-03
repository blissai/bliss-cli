module Configuration
  include Gitbase
  def load_configuration
    # Load configuration File if it exists
    @conf_dir = File.expand_path('~/.bliss')
    @conf_path = "#{@conf_dir}/config.yml"
    if File.exist? @conf_path
      @config = YAML.load_file(@conf_path)
    else
      @config = {}
    end
  end

  def set_host
    @config['BLISS_HOST'] ||= 'https://blissai.com'
  end

  def configured?
    !@config['TOP_LVL_DIR'].empty? && !@config['ORG_NAME'].empty? && !@config['API_KEY'].empty? && !@config['BLISS_HOST'].empty?
  end

  def format_arg(env, arg)
    return arg.strip.tr(' ', '-') if env.eql? 'ORG_NAME'
    arg
  end

  def valid_arg?(env, arg)
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

  # Checks for saved argument in config file, otherwise prompts user
  def sync_arg(message, env_name)
    if @config && @config[env_name]
      # Backwards compatibility
      unformatted = @config[env_name]
      @config[env_name] = format_arg(env_name, unformatted)
      puts "Loading #{env_name} from ~/.bliss/config.yml...  #{@config[env_name]}".blue
    else
      puts message.blue
      arg = $stdin.gets.chomp
      arg = File.expand_path(arg) if env_name.eql? 'TOP_LVL_DIR'
      valid = valid_arg?(env_name, arg)
      if !valid[:valid]
        sync_arg(valid[:msg], env_name)
      else
        @config[env_name] = format_arg(env_name, arg)
      end
    end
  end
end
