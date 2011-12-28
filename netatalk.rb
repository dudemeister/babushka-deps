dep "netatalk.complete" do
  requires "mdns.complete", "libssl-dev.managed", "libacl1-dev.managed", "libwrap0-dev.managed", "libgcrypt11-dev.managed", "libdb4.8.managed", "libdb4.8-dev.managed", "cups.src", "netatalk.source", "enable timemachine volumes"
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

dep "netatalk.source" do
  met? {
    which('netatalk-config')
  }
  meet {
    cd('/tmp') { |path|
      log_shell "downloading netatalk", "curl -LO http://downloads.sourceforge.net/project/netatalk/netatalk/2.2.1/netatalk-2.2.1.tar.gz", {:spinner => true}
      log_shell "expanding", "tar xzf netatalk-2.2.1.tar.gz", {:spinner => true}
      # hostapd needs to build in the hostapd dir
      cd("netatalk-2.2.1") { |path|
        log_shell "configuring", "./configure --enable-debian"
        log_shell "making", "make", {:spinner => true}
        log_shell "installing", "make install", {:spinner => true, :sudo => true}
      }
    }
  }
end

dep "enable timemachine volumes" do
  
  def config_path
    "/usr/local/etc/netatalk/AppleVolumes.default"
  end
  
  def section_name
    "home_shares"
  end
  
  met? {
    grep(/^~ options:tm$/, "#{config_path}")
  }
  meet {
    sudo("ruby -pi -e \"gsub(/^~$/, '~ options:tm')\" #{config_path}")
    sudo("/etc/init.d/netatalk restart")
  }
end

# sudo /etc/init.d/netatalk restart

# add to monitoring
