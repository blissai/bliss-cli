# Anlyzes directories to enfoce size limits
class DirectoryAnalyzer
  THRESHOLD = 100_000_0
  attr_reader :directory
  attr_reader :messages
  attr_reader :total_lines

  def initialize(dir)
    @directory = File.expand_path(dir)
    analyze
  end

  private

  def analyze
    @messages = []
    if !File.exist? @ddirectory
      @messages.push("#{@directory} is not a valid directory.".red)
    else
      @messages.push(too_big?)
    end
    @messages.keep_if { |m| !m.nil? }
  end

  def too_big?
    calculate_total_lines
    if @total_lines > THRESHOLD
      return "This repository exceeds 1 million lines of code and looks consistent of different projects or subsections of code.\n" \
      "In order to properly run static analysis, we need to break this up.\n" \
      'Please specify a sub directory to run over first (e.g. the root directory for a Rails/NodeJS or Java project within this repository).'.yellow
    end
    nil
  end

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
