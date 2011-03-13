spec = Gem::Specification.new do |s|
  s.name = 'no_userpic'
  s.version = '0.1'
  s.summary = 'Identicon generator, translated from wp_identicon'
  s.authors = ['Dmitry Grigoriev', 'Scott Sherrill-Mix']
  s.add_dependency('rmagick')
  s.description = "Identicon generator library, based (read: translated form php to ruby) on WP_Identicon code by Scott Sherrill-Mix. (Will be) able to write images to file or send through HTTP (with Metal)"
  s.email = ['dmitry@dxfoto.ru', '']
  s.extra_rdoc_files = ['README']
  s.files = ['lib/no_userpic.rb', 'bin/no_userpic']
  s.homepage = 'http://dev.dxfoto.ru/projects/nouserpic-dev'
  
end
