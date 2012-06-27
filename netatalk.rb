dep "netatalk.complete" do
  requires "mdns.complete", "libssl-dev.managed", "libacl1-dev.managed", "libwrap0-dev.managed", "libgcrypt11-dev.managed", "libdb4.8.managed", "libdb4.8-dev.managed", "libpam0g-dev.managed", "libpam-devperm.managed", "cups.src", "netatalk.source", "netatalk permissions", "enable timemachine volumes"
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

dep "netatalk.source" do
  met? {
    which('netatalk-config')
  }
  meet {
    cd('/tmp') { |path|
      log_shell "downloading netatalk", "curl -LO http://downloads.sourceforge.net/project/netatalk/netatalk/2.2.3/netatalk-2.2.3.tar.gz", {:spinner => true}
      log_shell "expanding", "tar xzf netatalk-2.2.3.tar.gz", {:spinner => true}
      # hostapd needs to build in the hostapd dir
      cd("netatalk-2.2.3") {
        log_shell "configuring", "./configure --enable-debian --with-pam"
        log_shell "making", "make", {:spinner => true}
        log_shell "installing", "make install", {:spinner => true, :sudo => true}
      }
    }
  }
  
end

dep "netatalk permissions" do
  def config_path
    "/usr/local/etc/netatalk/AppleVolumes.default"
  end
  
  met? {
    grep(/":DEFAULT: options:upriv,usedots dperm:0770 fperm:0660 umask:0007"/, "#{config_path}")
  }
  meet{
    old_defaults = ":DEFAULT: options:upriv,usedots"
    new_defaults = ":DEFAULT: options:upriv,usedots dperm:0770 fperm:0660 umask:0007"
    ruby = which("ruby")
    sudo("#{ruby} -pi -e \"gsub(/^#{old_defaults}$/, '#{new_defaults}')\" #{config_path}")    
  }
end

dep "enable timemachine volumes" do
  
  def config_path
    "/usr/local/etc/netatalk/AppleVolumes.default"
  end
  
  met? {
    grep(/^~ options:tm$/, "#{config_path}")
  }
  meet {
    ruby = which("ruby")
    sudo("#{ruby} -pi -e \"gsub(/^~$/, '~ options:tm')\" #{config_path}")
    sudo("/etc/init.d/netatalk restart")
  }
end

# sudo /etc/init.d/netatalk restart

# add to monitoring
