Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'mail_chimp'
  s.version     = '0.0.1'
  s.summary     = 'Add gem summary here'
  #s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'bzt'
  # s.email             = ''
  # s.homepage          = ''
  # s.rubyforge_project = ''

  s.files        = Dir['README.textile', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.30.0')
  s.add_dependency('hominid', '>= 2.2.0')
end