# taken from http://github.com/tricycle/babushka-deps and adapted for my needs (same for apache2/*) 
# hard works been done by them ;)
meta :apache2 do
  template {
    helper(:apachectl_command) { |command| "/usr/sbin/apache2ctl #{command}" }
    helper(:apachectl) { |command| sudo apachectl_command(command) }
    helper(:config_path) { '/etc/apache2' }

    helper :apache2_running? do
      shell "netstat -an | grep -E '^tcp.*[.:]80 +.*LISTEN'"
    end

    helper :restart_gracefully do
      if apache2_running?
        log_shell "Restarting apache2", apachectl_command("graceful"), :sudo => true
      end
    end

    helper(:vhost_config_path) { |domain| config_path / "sites-available/#{domain}" }
    helper(:site_available?) { |domain| shell "[ -e #{vhost_config_path(domain)} ]" }
    helper(:site_enabled?) { |domain| shell "[ -e #{config_path}/sites-enabled/*#{domain} ]" }
    helper(:site_disabled?) { |domain| not site_enabled?(domain) }
    helper(:enable_site) { |domain| sudo "a2ensite #{domain}" }
    helper(:disable_site) { |domain| sudo "a2dissite #{domain}" }

    helper(:mod_enabled?) { |mod| shell "[ -e #{config_path}/mods-enabled/#{mod}.load ]" }
    helper(:mod_disabled?) { |mod| not mod_enabled?(mod) }
    helper(:enable_mod) { |mod| sudo "a2enmod #{mod}" }
    helper(:disable_mod) { |mod| sudo "a2dismod #{mod}" }
  }
end

pkg 'apache2' do
  installs %w[apache2 apache2-mpm-prefork]
end

pkg 'apache2 dev packages' do
  installs %w[apache2-prefork-dev libapr1-dev libaprutil1-dev]
  provides %w[apxs2 apr-config]
end

apache2 'apache2 configured' do
  requires 'apache2'

  met? {
    [
      config_path / "mods-available/status.conf",
      config_path / "conf.d/types.conf",
      config_path / "conf.d/virtualhost.conf",
      "/etc/logrotate.d/apache2"
    ].all? { |file|
      babushka_config? file
    }
  }

  meet {
    # stub out the default status location
    render_erb 'apache2/status.conf.erb',      :to => config_path / 'mods-available/status.conf', :sudo => true
    # include custom types
    render_erb 'apache2/types.conf.erb',       :to => config_path / 'conf.d/types.conf', :sudo => true
    # configure the virtualhost conf
    render_erb 'apache2/virtualhost.conf.erb', :to => config_path / 'conf.d/virtualhost.conf', :sudo => true
    # configure logrotate
    render_erb 'apache2/logrotate.erb',        :to => '/etc/logrotate.d/apache2', :sudo => true
  }

  after { restart_gracefully }
end

apache2 'apache2 default site disabled' do
  met? { site_disabled? 'default' }
  meet { disable_site 'default' }
  after { restart_gracefully }
end

apache2 'apache2 running' do
  requires 'apache2 configured'
  met? { apache2_running? }
  meet {
    apachectl "start"
  }
end

apache2 'apache2 mod_rewrite enabled' do
  setup { set :module_name, 'rewrite' }
  requires 'apache2 module enabled'
end

apache2 'apache2 vhost enabled' do
  requires 'apache2'
  met? { site_enabled? var(:domain) }
  meet { enable_site var(:domain) }
  after { restart_gracefully }
end

apache2 'apache2 module enabled' do
  requires 'apache2'
  met? { mod_enabled? var(:module_name) }
  meet { enable_mod var(:module_name) }
  after { restart_gracefully }
end

dep 'apache2 runs on boot' do
  requires 'apache2'
  requires 'rcconf'
  met? { shell("rcconf --list").val_for('apache2') == 'on' }
  meet { sudo "update-rc.d apache2 defaults" }
end

apache2 'apache2 passenger vhost configured' do
  requires 'apache2 passenger configured'

  met? {
    site_available?(var(:domain)) && babushka_config?(vhost_config_path(var(:domain)))
  }
  meet {
    render_erb 'apache2/passenger_vhost.conf.erb', :to => vhost_config_path(var(:domain)), :sudo => true
  }
end
