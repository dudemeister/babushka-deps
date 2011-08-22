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
  source "http://www.rabbitmq.com/releases/rabbitmq-server/v2.5.1/rabbitmq-server-2.5.1.tar.gz"
  provides ["rabbitmq-server"]
end