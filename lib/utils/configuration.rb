module Configuration
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
    @config['BLISS_HOST'] ||= 'https://app.founderbliss.com'
  end

  def configured?
    !@config['TOP_LVL_DIR'].empty? && !@config['ORG_NAME'].empty? && !@config['API_KEY'].empty? && !@config['BLISS_HOST'].empty?
  end
end
