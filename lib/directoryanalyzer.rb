class DirectoryAnalyzer
  THRESHOLD =
  def initialize(dir)
    @dir = dir
  end

  def warnings
    warnings = []
    warnings.push(warning) if too_big?
  end

  def size
  end

  def too_big?
    warning = "This repository exceeds 500k lines of code and looks consistent of different projects or subsections of code.\n"
    warning += "In order to properly run static analysis, we need to break this up.\n"
    warning += 'Please specify a sub directory to run over first (e.g. the root directory for say a Rails/NodeJS or Java project within this repository).'
    warning
  end

  def total_lines
    cmd = "find . -type f \( #{supported_files} \) -exec cat -- {} + | wc -l"
    cmd
  end

  def supported_files
    langs = ['sh', 'rb', 'py', 'go', 'm', 'mm', 'h', 'cpp', 'css', 'js', 'class', 'java', 'php', 'bat', 'ps1', 'swift', 'f', 'pm', 'pl']
    '-name "' + langs.join('" -o -name "*.') + '"'
  end
end
