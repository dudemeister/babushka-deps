dep 'sqlite3.7' do
  requires 'python-software-properties.managed'
  met? {
    shell("sqlite3 -version").match(/3\.7/)
  }
  meet {
    if !shell('ls /etc/apt/sources.list.d/aleksander-m-sqlite3*')
      puts 'adding recent sqlite build repository'
      sudo "add-apt-repository ppa:aleksander-m/sqlite3"
      sudo "apt-get update"
    end
    Babushka::Base.host.pkg_helper.install!("sqlite3")
  }
end

dep 'python-software-properties.managed' do
  provides []
end
