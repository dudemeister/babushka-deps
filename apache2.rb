# taken from http://github.com/tricycle/babushka-deps and adapted for my needs (same for apache2/*) 
# hard works been done by them ;)
meta :apache2 do
  template {
    def apachectl_command(command)
      "/usr/sbin/apache2ctl #{command}"
    end
    def apachectl(command)
      sudo apachectl_command(command)
    end
    def config_path
      '/etc/apache2'
    end
    def apache2_running?
      shell "netstat -an | grep -E '^tcp.*[.:]80 +.*LISTEN'"
    end
    def restart_gracefully
      if apache2_running?
        log_shell "Restarting apache2", apachectl_command("graceful"), :sudo => true
      end
    end
    def vhost_config_path(domain)
      config_path / "sites-available/#{domain}"
    end
    def site_available?(domain)
      shell "[ -e #{vhost_config_path(domain)} ]"
    end
    def site_enabled?(domain)
      shell "[ -e #{config_path}/sites-enabled/*#{domain} ]"
    end
    def site_disabled?(domain)
      not site_enabled?(domain)
    end
    def enable_site(domain)
      sudo "a2ensite #{domain}"
    end
    def disable_site(domain)
      sudo "a2dissite #{domain}"
    end
    def mod_enabled?(mod)
      shell "[ -e #{config_path}/mods-enabled/#{mod}.load ]"
    end
    def mod_disabled?(mod)
      not mod_enabled?(mod)
    end
    def enable_mod(mod)
      sudo "a2enmod #{mod}"
    end
    def disable_mod(mod)
      sudo "a2dismod #{mod}"
    end
  }
end

dep 'apache2', :template => 'managed' do
  installs %w[apache2 apache2-mpm-prefork]
end

dep 'apache2 dev packages', :template => 'managed' do
  installs %w[apache2-prefork-dev libapr1-dev libaprutil1-dev]
  provides %w[apxs2 apr-config]
end

dep 'configured.apache2' do
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

dep 'default site disabled.apache2' do
  met? { site_disabled? 'default' }
  meet { disable_site 'default' }
  after { restart_gracefully }
end

dep 'running.apache2' do
  requires 'configured.apache2'
  met? { apache2_running? }
  meet {
    apachectl "start"
  }
end

dep 'mod_rewrite enabled.apache2' do
  setup { set :module_name, 'rewrite' }
  requires 'module enabled.apache2'
end

dep 'proxy enabled.apache2' do
  setup { set :module_name, 'proxy' }
  requires 'module enabled.apache2'
end

dep 'proxy_http enabled.apache2' do
  setup { set :module_name, 'proxy_http' }
  requires 'module enabled.apache2'
end

dep 'proxy_connect enabled.apache2' do
  setup { set :module_name, 'proxy_connect' }
  requires 'module enabled.apache2'
end

dep 'ssl enabled.apache2' do
  setup { set :module_name, 'ssl' }
  requires 'module enabled.apache2'
end

dep 'headers enabled.apache2' do
  setup { set :module_name, 'headers' }
  requires 'module enabled.apache2'
end

dep 'include enabled.apache2' do
  setup { set :module_name, 'include' }
  requires 'module enabled.apache2'
end

dep 'dav enabled.apache2' do
  setup { set :module_name, 'dav' }
  requires 'module enabled.apache2'
end

dep 'dav_fs enabled.apache2' do
  setup { set :module_name, 'dav_fs' }
  requires 'module enabled.apache2'
end

dep 'authnz_external enabled.apache2' do
  setup { set :module_name, 'authnz_external' }
  requires 'module enabled.apache2'
end

dep 'vhost enabled.apache2' do
  requires 'apache2'
  met? { site_enabled? var(:domain) }
  meet { enable_site var(:domain) }
  after { restart_gracefully }
end

dep 'module enabled.apache2' do
  requires 'apache2'
  met? { mod_enabled? var(:module_name) }
  meet { enable_mod var(:module_name) }
  after { restart_gracefully }
end

dep 'libapache2-mod-authz-unixgroup.managed' do
  provides []
end

dep "pwauth.managed"

dep "pwauth unixgroup" do
  met? { which("unixgroup") }
  meet {
    cd("/tmp") do
      log_shell "cleaning   ", "rm -f pwauth-2.3.10.tar.gz; rm -rf pwauth-2.3.10"
      log_shell "downloading", "wget -O pwauth-2.3.10.tar.gz 'http://pwauth.googlecode.com/files/pwauth-2.3.10.tar.gz'"
      if File.exists?("pwauth-2.3.10.tar.gz")
        log_shell "unpacking  ", "tar xzf pwauth-2.3.10.tar.gz"
        log_shell "moving     ", "sudo mv pwauth-2.3.10/unixgroup /usr/local/bin/"
      end
    end
  }
end

dep 'webdav authorization tools' do
  requires "libapache2-mod-authz-unixgroup.managed", "pwauth.managed", "pwauth unixgroup", "authnz_external enabled.apache2", "fix apache2 permissions with udev"

  met? {
    !sudo('cat /etc/apache2/envvars').split("\n").grep(/protonet-webdav-umask/).empty?
  }
  meet {
    umask = "umask u=rwx,g=rwx,o="
    append_to_file_with_section umask, "/etc/apache2/envvars", 'protonet-webdav-umask', {:sudo => true}
  }
end

dep 'fix apache2 permissions with udev' do
  met? {
    grep "protonet-umask-fix", '/usr/sbin/apache2ctl'
  }
  meet {
    config = <<-EOS
# START protonet-umask-fix
if [ "$ARGV" = "start" ] || [ "$ARGV" = "restart" ]; then
  CHECK_COUNTER=0
  echo "waiting for pid"
  until [ -e "$APACHE_PID_FILE" ] || [ $CHECK_COUNTER -gt 3 ]; do
    echo "."
    CHECK_COUNTER=$((CHECK_COUNTER+1))
    sleep 1
  done
  if [ -e "$APACHE_PID_FILE" ]; then
    echo "fixing pid file"
    chmod 664 $APACHE_PID_FILE
  fi
fi
# END protonet-umask-fix

exit $ERROR
EOS
    change_line("exit $ERROR", config, "/usr/sbin/apache2ctl")
  }
end

dep 'apache2 runs on boot' do
  requires 'apache2'
  requires 'rcconf'
  met? { shell("rcconf --list").val_for('apache2') == 'on' }
  meet { sudo "update-rc.d apache2 defaults" }
end

dep 'passenger vhost configured.apache2' do
  requires 'apache2 passenger mods configured'

  met? {
    site_available?(var(:domain)) && babushka_config?(vhost_config_path(var(:domain)))
  }
  meet {
    if(var(:domain) == "admin")
      render_erb 'apache2/passenger_vhost_admin.conf.erb', :to => vhost_config_path(var(:domain)), :sudo => true
    else
      render_erb 'apache2/passenger_vhost.conf.erb', :to => vhost_config_path(var(:domain)), :sudo => true
    end
  }
end

dep 'apache2-prefork-dev.managed' do
  provides ["apxs2"]
end

dep 'xsendfile.apache2' do
  requires 'apache2-prefork-dev.managed'
  met? {
    !!sudo("a2enmod xsendfile")
  }
  meet {
    cd "/tmp" do
      log_shell "cleaning   ", "rm -rf mod_xsendfile.c"
      log_shell "downloading", "wget --no-check-certificate -O mod_xsendfile.c https://tn123.org/mod_xsendfile/mod_xsendfile.c"
      log_shell "installing",  "sudo apxs2 -cia mod_xsendfile.c"
    end
  }
  after { restart_gracefully }
end

dep 'websocket_proxy.apache2' do
  requires 'apache2-prefork-dev.managed'
  met? {
    ["websocket_vnc_proxy", "websocket", "websocket_draft76"].all? {|name| sudo("a2enmod #{name}") }
  }
  meet {
    cd "/tmp" do
      log_shell "cleaning   ", "sudo rm -rf apache-websocket"
      log_shell "cloning    ", "git clone git://github.com/protonet/apache-websocket.git"
      cd "apache-websocket" do
        ["mod_websocket_draft76.c", "mod_websocket.c"].each do |c_file|
          log_shell "installing ",  "sudo apxs2 -cia #{c_file}"
        end
        cd "vncproxy" do
          log_shell "installing ", "sudo apxs2 -cia -I.. mod_websocket_vnc_proxy.c"
        end
      end
    end
  }
  after { restart_gracefully }  
end

dep 'websocket_read_timeouts.apache2' do
  requires 'apache2-prefork-dev.managed'
  met? {
     grep "RequestReadTimeout body=30,MinRate=1", '/etc/apache2/mods-available/reqtimeout.conf'
  }
  meet {
    change_line "RequestReadTimeout body=10,minrate=500", "RequestReadTimeout body=30,MinRate=1", "/etc/apache2/mods-available/reqtimeout.conf"
  }
  after { restart_gracefully }
end

dep 'up_maxclient.apache2' do
  met? {
    !!grep(/MaxClients 256/, "/etc/apache2/apache2.conf")
  }
  meet {
    sudo("ruby -pi -e \"gsub(/MaxClients\s.*[0-9]*/, 'MaxClients 256')\" /etc/apache2/apache2.conf")
  }
end

dep 'prepare apache2 envvars for precise' do

  met? {
    !sudo('cat /etc/apache2/envvars').split("\n").grep(/protonet-envvars/).empty?
  }
  meet {
    vars = <<-EOF
# this won't be correct after changing uid
unset HOME

# for supporting multiple apache2 instances
if [ "${APACHE_CONFDIR##/etc/apache2-}" != "${APACHE_CONFDIR}" ] ; then
        SUFFIX="-${APACHE_CONFDIR##/etc/apache2-}"
else
        SUFFIX=
fi

# Since there is no sane way to get the parsed apache2 config in scripts, some
# settings are defined via environment variables and then used in apache2ctl,
# /etc/init.d/apache2, /etc/logrotate.d/apache2, etc.
export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data
export APACHE_PID_FILE=/var/run/apache2$SUFFIX.pid
export APACHE_RUN_DIR=/var/run/apache2$SUFFIX
export APACHE_LOCK_DIR=/var/lock/apache2$SUFFIX
# Only /var/log/apache2 is handled by /etc/logrotate.d/apache2.
export APACHE_LOG_DIR=/var/log/apache2$SUFFIX

EOF

    append_to_file_with_section vars, "/etc/apache2/envvars", 'protonet-envvars', {:sudo => true}
  }
end