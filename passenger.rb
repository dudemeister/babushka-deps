dep 'passenger' do
  requires 'zlib headers.managed'
  met? { 
    which("passenger-install-apache2-module")
  }
  meet {
    shell("gem install passenger")
  }
end

dep 'apache2 passenger mods configured' do
  requires 'apache2'
  requires_when_unmet 'build tools', 'apache2 dev packages', 'libcurl4-openssl-dev.managed'
  setup {
    set :passenger_root, Babushka::GemHelper.gem_path_for('passenger')
    set :ruby, "/usr/local/rvm/wrappers/ruby-1.9.3-p125/ruby"
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
    shell "rvmsudo passenger-install-apache2-module -a"
    render_erb 'passenger/passenger.load.erb', :to => '/etc/apache2/mods-available/passenger.load', :sudo => true
    render_erb 'passenger/passenger.conf.erb', :to => '/etc/apache2/mods-available/passenger.conf', :sudo => true
  }
end

dep 'apache2 passenger mods enabled' do
  requires 'apache2 passenger mods configured'
  setup { set :module_name, 'passenger' }
  requires 'module enabled.apache2'
end

dep 'passenger3', :template => 'gem' do
  requires "apache2 dev packages"
  installs 'passenger = 3.0.5'
  provides 'passenger-install-apache2-module'
end

dep 'libcurl4-openssl-dev.managed' do
  provides []
end