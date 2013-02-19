dep "netatalk.complete" do
  requires  "cups.managed", "libpam0g-dev.managed", 
            "libdb4.8.managed", "libdb4.8-dev.managed", 
            "netatalk.source", "netatalk config", "libavahi-client-dev.managed"
end

dep "libssl-dev.managed" do
  provides []
end

dep "libacl1-dev.managed" do
  provides []
end

dep "libwrap0-dev.managed" do
  provides []
end

dep "libgcrypt11-dev.managed" do
  provides []
end

dep "libdb4.8.managed" do
  provides []
end

dep "libdb4.8-dev.managed" do
  provides []
end

dep "libpam0g-dev.managed" do
  provides []
end

dep "libpam-devperm.managed" do
  provides []
end

dep "libavahi-client-dev.managed" do
  provides []
end

dep "netatalk.source" do
  met? {
    which('netatalk-config') && shell("netatalk-config --version") == "3.0.2"
  }
  meet {
    cd('/tmp') { |path|
      log_shell "downloading netatalk", "curl -LO http://downloads.sourceforge.net/project/netatalk/netatalk/3.0.2/netatalk-3.0.2.tar.gz", {:spinner => true}
      log_shell "expanding", "tar xzf netatalk-3.0.2.tar.gz", {:spinner => true}
      cd("netatalk-3.0.2") {
        log_shell "configuring", "./configure --enable-debian --with-pam --with-init-style=debian"
        log_shell "making", "make", {:spinner => true}
        log_shell "installing", "make install", {:spinner => true, :sudo => true}
      }
    }
  }
end

dep "netatalk config" do
  met? { 
    babushka_config? "/usr/local/etc/afp.conf"
  }
  meet { 
    render_erb "netatalk/afp.conf.erb", :to => "/usr/local/etc/afp.conf", :sudo => true
  }
  after {
    sudo "/etc/init.d/netatalk restart"
  }
end
