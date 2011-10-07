dep 'rabbitmq-server', :template => 'managed'

# this one add a line to the init script so rabbitmq writes out a monit understandable pidfile
# based on http://blog.joeygeiger.com/2009/02/25/rabbitmq-and-monit/
dep 'rabbitmq-with-pid' do
  met? {
     grep("mkdir -p -m 0777 /var/run/rabbitmq", '/etc/init.d/rabbitmq-server')
  }
  meet {
    change_line("PID_FILE=/var/run/rabbitmq/pid",
      "PID_FILE=/var/run/rabbitmq/pid\nchown root:admin /var/run\nchmod g+rwx /var/run\nmkdir -p -m 0777 /var/run/rabbitmq",
      "/etc/init.d/rabbitmq-server")
    # stop and restart the rabbitmq server to reflect changes
    sudo("/etc/init.d/rabbitmq-server restart >/dev/null 2>&1")
  }
end


dep 'erlang-nox.managed' do
  provides []
end

dep 'rabbitmq.src' do
  requires "erlang-nox.managed"
  source "https://github.com/downloads/protonet/custom_debs/rabbitmq-server_2.6.0-1_all.custom.deb"
  process_source {
    sudo("dpkg -i --force-confnew --force-confmiss rabbitmq-server_2.6.0-1_all.custom.deb")
    if File.exists?("/etc/init.d/rabbitmq-server.dpkg-dist")
      sudo("mv -f /etc/init.d/rabbitmq-server.dpkg-dist /etc/init.d/rabbitmq-server")
    end
    sudo("chmod +x /etc/init.d/rabbitmq-server")
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
    shell("/home/protonet/dashboard/current/script/init/app_monit stop")
    sudo("/etc/init.d/rabbitmq-server stop")
    binaries.each do |cmd|
      sudo("rm -rf `which #{cmd}`")
    end
    # also get rid of the init.d
    sudo("rm -rf /etc/init.d/rabbitmq-server")
  }
end

dep 'rabbitmq update' do
  requires 'rabbitmq remove', 'rabbitmq.src', 'rabbitmq-with-pid'
end