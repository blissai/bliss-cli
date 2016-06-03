module Cmd
  def help(arg)
    unless valid(arg)
      puts 'Usage:'
      puts "bliss run \t\t Run the CLI."
      puts "bliss init \t\t Send preliminary repository data to Bliss."
      puts "bliss help\t\t Display this help message."
      exit
    end
  end

  def version(arg)
    if %w(-v --version version).include?(arg)
      puts $VERSION
      exit
    end
  end

  def valid(arg)
    %w(run init start stop status -v --version version stats lint).include?(arg)
  end
end
