gem 'passenger' do
  installs 'passenger' => '= 2.2.9'
  provides 'passenger-install-apache2-module'
end

dep 'apache2 passenger module built' do
  requires 'passenger'
  requires_when_unmet 'build tools', 'apache2 dev packages'
  met? {
    "/usr/lib/ruby/gems/1.8/gems/passenger-2.2.9/ext/apache2/mod_passenger.so".p.exists?
  }
  meet {
    sudo "passenger-install-apache2-module -a"
  }
end

dep 'apache2 passenger configured' do
  requires 'apache2 passenger module built'

  setup {
    set :passenger_root, "/usr/lib/ruby/gems/1.8/gems/passenger-2.2.9"
  }

  met? {
    [ 
      "mods-available/passenger.conf",
      "mods-available/passenger.load"
    ].all? { |file|
      babushka_config?("/etc/apache2" / file)
    }
  }

  meet {
    render_erb 'passenger/passenger.load.erb', :to => '/etc/apache2/mods-available/passenger.load', :sudo => true
    render_erb 'passenger/passenger.conf.erb', :to => '/etc/apache2/mods-available/passenger.conf', :sudo => true
  }
end

dep 'apache2 passenger module enabled' do
  setup { set :module_name, 'passenger' }
  requires 'apache2 passenger configured', 'apache2 module enabled'
end
