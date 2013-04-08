dep 'rabbitmq-server', :template => 'managed'
dep 'rabbitmq-server.managed'

dep 'erlang-nox.managed' do
  provides []
end

dep 'rabbitmq.src' do
  requires "erlang-nox.managed"
  source "https://github.com/downloads/protonet/custom_debs/rabbitmq-server_2.6.1-1_all.custom.deb"
  process_source {
    sudo("dpkg -i --force-confnew --force-confmiss rabbitmq-server_2.6.1-1_all.custom.deb")
    if File.exists?("/etc/init.d/rabbitmq-server.dpkg-dist")
      sudo("mv -f /etc/init.d/rabbitmq-server.dpkg-dist /etc/init.d/rabbitmq-server")
    end
    sudo("chmod +x /etc/init.d/rabbitmq-server")
    sudo("/etc/init.d/rabbitmq-server start > /dev/null 2>&1")
  }
  provides ["rabbitmq-server"]
end

dep 'rabbitmq-server-304.src' do
  requires "erlang-nox.managed"
  source "http://www.rabbitmq.com/releases/rabbitmq-server/v3.0.4/rabbitmq-server_3.0.4-1_all.deb"
  process_source {
    sudo("dpkg -i rabbitmq-server_3.0.4-1_all.deb")
  }
  provides ["rabbitmq-server"]
end

dep 'add rabbitmqadmin' do
  met? {
    which("rabbitmqadmin")
  }
  meet {
    sudo("wget -O /usr/sbin/rabbitmqadmin -L http://localhost:15672/cli/rabbitmqadmin")
    sudo("chmod +x /usr/sbin/rabbitmqadmin")
  }
end

dep 'enable rabbitmq management plugin' do
  met? {
    system("rabbitmq-plugins list -E rabbitmq_management | grep rabbitmq_management")
  }
  meet {
    sudo("rabbitmq-plugins enable rabbitmq_management")
    sudo("service rabbitmq-server restart")
  }
end

dep "stop rabbitmq" do
  requires 'rabbitmq-server-304.src'
  met? { !sudo("/etc/init.d/rabbitmq-server status", as: "root")  }
  meet { sudo("/etc/init.d/rabbitmq-server stop", as: "root") }
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

dep 'rabbitmq remove autostart' do
  def paths
    ["/etc/rc0.d/K20rabbitmq-server", "/etc/rc1.d/K20rabbitmq-server", "/etc/rc2.d/S20rabbitmq-server",
     "/etc/rc3.d/S20rabbitmq-server", "/etc/rc4.d/S20rabbitmq-server", "/etc/rc5.d/S20rabbitmq-server"]
  end
  met? {
    paths.all? do |path|
      !File.exists?("/etc/rc0.d/K20rabbitmq-server")
    end
  }
  meet {
    sudo("rm -rf #{paths.join(" ")}")
  }
end

dep 'rabbitmq update' do
  requires 'rabbitmq remove', 'rabbitmq304.src', 'rabbitmq remove autostart'
end