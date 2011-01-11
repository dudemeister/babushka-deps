dep 'coffeescript.src' do
  requires 'node.src'
  source 'git://github.com/jashkenas/coffee-script.git'
  provides 'coffee ~> 0.9.6'

  configure { true }
  build { shell "bin/cake build" }
  install { shell "bin/cake install" }
end