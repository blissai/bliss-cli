$LOAD_PATH.unshift(File.join(__FILE__, '../lib'))

Gem::Specification.new do |s|
  s.name        = 'bliss'
  s.version     = '1.0.0'
  s.summary     = 'Bliss Enterprise'
  s.license     = 'MIT'
  s.authors     = 'Bliss'
  s.email       = 'hello@bliss.ai'
  s.homepage    = 'https://bliss.ai'
  s.description = 'Bliss command line tool'

  s.files         = Dir['lib/**/*.rb'] + Dir['blisscollector.rb']
  s.require_paths = ['lib']
  s.bindir        = 'bin'
  s.executables   = %w(bliss)

  s.add_dependency 'colorize'
  s.add_dependency 'whenever'
  s.add_dependency 'io-console'
end
