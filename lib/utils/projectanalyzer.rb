class ProjectAnalyzer
  attr_reader :directory
  attr_reader :total_lines

  def initialize(git_dir, max_lines = 750000)
    @max_lines = max_lines
    update_directory(git_dir)
    calculate_total_lines
  end

  def update_directory(git_dir)
    @directory = git_dir
    calculate_total_lines
  end

  def too_big?
    @total_lines > @max_lines
  end

  private

  def calculate_total_lines
    cmd = "find #{@directory} -type f \\( #{supported_files} \\) -exec cat -- {} + | wc -l"
    @total_lines = `#{cmd}`.strip.to_i
  end

  # Supported extensions to search for
  def supported_files
    langs = %w(sh rb py go m mm h cpp css js class java php bat ps1 swift f pm pl)
    '-name "' + langs.join('" -o -name "*.') + '"'
  end
end
