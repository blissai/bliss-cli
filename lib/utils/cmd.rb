module Cmd
  def help
    if arg.eql?('help') || arg.eql?('--help')
      puts 'Usage:'
      puts "bliss\t\t\t Run the CLI."
      puts "bliss init \t\t Send preliminary repository data to Bliss."
      puts "bliss help\t\t Display this help message."
      exit
    end
  end

  def version(arg, override = false)
    if arg.eql?('version') || arg.eql?('-v') || arg.eql?('--version') || override
      puts $VERSION
      exit
    end
  end
end
