meta :rvm do
  def rvm args
    login_shell "rvm #{args}", :log => args['install']
  end
end

dep '1.9.3-p392.rvm' do
  requires '1.9.3 installed.rvm'
  met? {
    login_shell('ruby --version') && login_shell('ruby --version')['ruby 1.9.3p392']
  }
  meet { sudo("/bin/bash", :input => 'rvm alias create default 1.9.3-p392', :su => true) }
end

dep '1.9.3-p374.rvm' do
  requires '1.9.3 installed.rvm'
  met? { 
    login_shell('ruby --version') && login_shell('ruby --version')['ruby 1.9.3p374']
  }
  meet { sudo("/bin/bash", :input => 'rvm alias create default 1.9.3-p374', :su => true) }
end


dep 'zlib.rvm' do
  requires 'rvm'
  met? {
    File.exists?("/usr/local/rvm/usr/lib/pkgconfig/zlib.pc")
  }
  meet {
    sudo("/bin/bash", :input => 'rvm pkg install zlib', :su => true)
  }
end

dep 'openssl.rvm' do
  requires 'rvm'
  met? {
    File.exists?("/usr/local/rvm/usr/lib/pkgconfig/openssl.pc")
  }
  meet {
    sudo("/bin/bash", :input => 'rvm pkg install openssl', :su => true)
  }
end

dep '1.9.3 installed.rvm' do
  requires 'rvm'
  met? {
    rvm('list')['ruby-1.9.3-p392']
  }
  meet {
    log('rvm install 1.9.3-p392'){
      sudo("/bin/bash", :input => 'rvm install 1.9.3-p392', :su => true)
    }
  }
  after{
    sudo("apt-get -y purge ruby-enterprise* ruby1.8* ruby1.8-dev*") &&
      sudo("rm -rf /usr/local/lib/ruby")
  }
end

dep 'rvm' do
  requires 'curl'
  met? { login_shell('which rvm') }
  meet {
    sudo("/bin/bash", :input => `curl -L get.rvm.io`)
    sudo 'usermod -a -G rvm protonet'
    sudo 'usermod -a -G rvm root'
  }
  after {
    # additional dependencies for Ruby (rvm requirements)
    sudo "/usr/bin/apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion"
  }
end

dep '1.9.2.rvm' do
  requires '1.9.2 installed.rvm'
  met? { login_shell('ruby --version')['ruby 1.9.2p0'] }
  meet { rvm('use 1.9.2 --default') }
end

dep '1.9.2 installed.rvm' do
  requires 'rvm'
  met? { rvm('list')['ruby-1.9.2-p0'] }
  meet { log("rvm install 1.9.2") { rvm 'install 1.9.2'} }
end



meta :rvm_mirror do
  def urls
    shell("grep '_url=' ~/.rvm/config/db").split("\n").reject {|l|
      l['_repo_url']
    }.map {|l|
      l.sub(/^.*_url=/, '')
    }
  end
  template {
    requires 'rvm'
  }
end

dep 'mirrored.rvm_mirror' do
  define_var :rvm_vhost_root, :default => '/srv/http/rvm'
  def missing_urls
    urls.tap {|urls| log "#{urls.length} URLs in the rvm database." }.reject {|url|
      path = var(:rvm_vhost_root) / url.sub(/^[a-z]+:\/\/[^\/]+\//, '')
      path.exists? && !path.empty?
    }.tap {|urls| log "Of those, #{urls.length} aren't present locally." }
  end
  met? { missing_urls.empty? }
  meet {
    missing_urls.each {|url|
      cd(var(:rvm_vhost_root) / File.dirname(url.sub(/^[a-z]+:\/\/[^\/]+\//, '')), :create => true) do
        # begin
          Babushka::Resource.download url
        # rescue StandardError => ex
        #   log_error ex.inspect
        # end
      end
    }
  }
  after {
    log urls.map {|url|
      url.scan(/^[a-z]+:\/\/([^\/]+)\//).flatten.first
    }.uniq.reject {|url|
      url[/[:]/]
    }.join(' ')
    log "Those are the domains you should point at #{var(:rvm_vhost_root)}."
  }
end
