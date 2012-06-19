# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_mail_chimp'
  s.version     = '3.0.2'
  s.summary     = 'Mail Chimp subscriptions for your Spree store using hominid'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Sam Beam'
  s.email             = 'sbeam@onsetcorps.net'
  s.homepage          = 'https://github.com/sbeam/spree-mail-chimp'


  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency 'spree_core', '~> 1.0'
  s.add_dependency 'hominid',    '~> 3.0.0'
end
