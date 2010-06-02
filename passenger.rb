gem 'passenger' do
  installs 'passenger' => '2.2.12'
  provides 'passenger-install-apache2-module'
end

dep 'apache2 passenger mods configured' do
  requires 'apache2', 'passenger'
  requires_when_unmet 'build tools', 'apache2 dev packages'
  setup {
    set :passenger_root, Babushka::GemHelper.gem_path_for('passenger')
  }

  met? {
    "#{var :passenger_root}/ext/apache2/mod_passenger.so".p.exists? && [ 
      "mods-available/passenger.conf",
      "mods-available/passenger.load"
    ].all? { |file|
      babushka_config?("/etc/apache2/#{file}")
    }
  }

  meet {
    sudo "passenger-install-apache2-module -a"
    render_erb 'passenger/passenger.load.erb', :to => '/etc/apache2/mods-available/passenger.load', :sudo => true
    render_erb 'passenger/passenger.conf.erb', :to => '/etc/apache2/mods-available/passenger.conf', :sudo => true
  }
end

dep 'apache2 passenger mods enabled' do
  requires 'apache2 passenger mods configured'
  setup { set :module_name, 'passenger' }
  requires 'apache2 module enabled'
end
