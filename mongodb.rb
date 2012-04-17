dep "mongodb.managed" do
  provides ["mongod"]
end

dep "dudemeister:mongodb only local connections" do
  met? {
    grep(/bind_ip = 127.0.0.1/, "/etc/mongodb.conf")
  }
  meet {
    sudo("bind_ip = 127.0.0.1' > /etc/mongodb.conf")
    sudo("/etc/init.d/mongodb restart")
  }
end