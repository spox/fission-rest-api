$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-rest-api/version'
Gem::Specification.new do |s|
  s.name = 'fission-rest-api'
  s.version = Fission::RestApi::VERSION.version
  s.summary = 'Fission REST API'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission-rest-api'
  s.description = 'Fission REST API'
  s.require_path = 'lib'
  s.add_dependency 'fission', '>= 0.3.0', '< 1.0'
  s.add_dependency 'carnivore-http'
#  s.add_dependency 'http' # <<---- This should NOT be needed but is
  # for java lib being dumb in deps
  s.files = Dir['{lib}/**/**/*'] + %w(fission-rest-api.gemspec README.md CHANGELOG.md)
end
