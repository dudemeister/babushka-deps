dep 'mysql.gem' do
  requires 'mysql.managed'
  provides []
end

dep 'mysql access' do
  requires 'existing mysql db'
  define_var :db_user, :default => :username
  define_var :db_host, :default => 'localhost'
  met? { mysql "use #{var(:db_name)}", var(:db_user) }
  meet { mysql %Q{GRANT ALL PRIVILEGES ON #{var :db_name}.* TO '#{var :db_user}'@'#{var :db_host}' IDENTIFIED BY '#{var :db_password}'} }
end

dep 'existing mysql db' do
  requires 'mysql configured'
  met? { mysql("SHOW DATABASES").split("\n")[1..-1].any? {|l| /\b#{var :db_name}\b/ =~ l } }
  meet { mysql "CREATE DATABASE #{var :db_name}" }
end

dep 'mysql configured' do
  requires 'mysql root password'
  requires 'mysql started'
end

dep 'mysql root password' do
  requires 'mysql.managed'
  met? { failable_shell("echo '\q' | mysql -u root").stderr["Access denied for user 'root'@'localhost' (using password: NO)"] }
  meet {
    failable_shell("killall mysqld", :sudo => true)
    Thread.new {
      sudo("mysqld_safe --skip-grant-tables")
    }
    sleep 3
    shell("mysql -e \"GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY ''\"")
    sudo("killall mysqld")
  }
end

dep 'mysql started' do
  met? {
    false
  }
  meet? {
    sudo("service mysql start")
  }
end

dep 'mysql.managed' do
  installs {
    via :apt, %w[mysql-server libmysqlclient-dev]
    via :macports, 'mysql5-server'
  }
  provides 'mysql'
  after :on => :osx do
    sudo "ln -s #{Babushka::MacportsHelper.prefix / 'lib/mysql5/bin/mysql*'} #{Babushka::MacportsHelper.prefix / 'bin/'}"
  end
end
