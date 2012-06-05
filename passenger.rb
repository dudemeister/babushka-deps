dep 'passenger' do
  requires 'zlib headers.managed'
  met? { 
    which("passenger-install-apache2-module")
  }
  meet {
    shell("gem install passenger -v 3.0.12")
  }
end

dep 'apache2 passenger mods configured' do
  requires 'apache2'
  requires_when_unmet 'build tools', 'apache2 dev packages', 'libcurl4-openssl-dev.managed'
  setup {
    passenger_path = begin
      Babushka::GemHelper.gem_path_for('passenger')
    rescue 
      login_shell("source /usr/local/rvm/scripts/rvm; echo $GEM_PATH").split(":").first + "/gems/passenger-3.0.12"
    end
    set :passenger_root, passenger_path
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
    shell "sudo su -l root -c \"passenger-install-apache2-module -a\""
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
  installs 'passenger = 3.0.12'
  provides 'passenger-install-apache2-module'
end

dep 'libcurl4-openssl-dev.managed' do
  provides []
end