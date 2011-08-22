dep 'rabbitmq-server', :template => 'managed'

# this one add a line to the init script so rabbitmq writes out a monit understandable pidfile
# based on http://blog.joeygeiger.com/2009/02/25/rabbitmq-and-monit/
dep 'rabbitmq-with-pid' do
  met? {
     grep(/rabbitmq\.pid/, '/etc/init.d/rabbitmq-server')
  }
  meet {
    change_line("echo SUCCESS",
      "$CONTROL status | grep \"pid,[0-9]*\" | grep -o \"[0-9]*\" > /var/run/rabbitmq.pid\necho SUCCESS",
      "/etc/init.d/rabbitmq-server")
    # stop and restart the rabbitmq server to reflect changes
    sudo("/etc/init.d/rabbitmq-server restart")
  puts "foo"
  }
end


dep 'erlang-nox.managed' do
  provides []
end

dep 'rabbitmq.src' do
  requires "erlang-nox.managed"
  source "http://www.rabbitmq.com/releases/rabbitmq-server/v2.5.1/rabbitmq-server_2.5.1-1_all.deb"
  process_source {
    sudo("dpkg -i --force-confnew rabbitmq-server_2.5.1-1_all.deb")
  }
  provides ["rabbitmq-server"]
end

dep 'rabbitmq remove' do
  def binaries
    ["rabbitmq-activate-plugins", "rabbitmq-multi", "rabbitmqctl", "rabbitmq-deactivate-plugins", "rabbitmq-server"]
  end
  met? {
    binaries.all? do |cmd|
      !which(cmd)
    end
  }
  meet {
    binaries.each do |cmd|
      sudo("rm -rf `which #{cmd}`")
    end
    # also get rid of the init.d
    sudo("rm -rf /etc/init.d/rabbitmq-server")
  }
end

dep 'rabbitmq update' do
  requires 'rabbitmq remove', 'rabbitmq.src'
end