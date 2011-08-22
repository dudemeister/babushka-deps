dep 'rabbitmq-server', :template => 'managed'

# this one add a line to the init script so rabbitmq writes out a monit understandable pidfile
# based on http://blog.joeygeiger.com/2009/02/25/rabbitmq-and-monit/
dep 'rabbitmq-with-pid' do
  met? {
     grep(/rabbitmq\.pid/, '/etc/init.d/rabbitmq-server')
  }
  meet {
    change_line("echo SUCCESS",
      "echo SUCCESS\nsed 's/.*,\\(.*\\)\\}.*/\\\\1/' /var/lib/rabbitmq/pids > /var/run/rabbitmq.pid",
      "/etc/init.d/rabbitmq-server")
    # stop and restart the rabbitmq server to reflect changes
    sudo("/etc/init.d/rabbitmq-server stop")
    sudo("/etc/init.d/rabbitmq-server start")
  }
end


dep 'rabbitmq.src' do
  source "http://www.rabbitmq.com/releases/rabbitmq-server/v2.5.1/rabbitmq-server_2.5.1-1_all.deb"
  process_source {
    sudo("dpkg -i rabbitmq-server_2.5.1-1_all.deb")
  }
  # met? { shell("ruby --version") =~ /#{Regexp.escape("ruby 1.8.7 (2010-04-19 patchlevel 253) [x86_64-linux], MBARI 0x6770, Ruby Enterprise Edition 2010.02")}/ }
  provides ["rabbitmq-server"]
end

dep 'rabbitmq remove' do
  met? {
    ["rabbitmq-activate-plugins", "rabbitmq-multi", "rabbitmqctl", "rabbitmq-deactivate-plugins", "rabbitmq-server"].all? do |cmd|
      !which(cmd)
    end
  }
  meet {
    ["rabbitmq-activate-plugins", "rabbitmq-multi", "rabbitmqctl", "rabbitmq-deactivate-plugins", "rabbitmq-server"].each do |cmd|
      sudo("rm -rf `which #{cmd}`")
    end
  }
end

dep 'rabbitmq update' do
  requires 'rabbitmq remove', 'rabbitmq.src'
end