dep "netatalk.complete" do
  requires "mdns.complete", "libssl-dev.managed", "libacl1-dev.managed", "libwrap0-dev.managed", "libgcrypt11-dev.managed", "libdb4.8.managed", "libdb4.8-dev.managed", "cups.src", "netatalk.src"
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

dep "netatalk.src" do
  source 'http://downloads.sourceforge.net/project/netatalk/netatalk/2.2.1/netatalk-2.2.1.tar.gz'
  provides ['afpd']
end

# sudo vim /usr/local/etc/netatalk/afpd.conf
# sudo vim /usr/local/etc/netatalk/AppleVolumes.system

# sudo /etc/init.d/netatalk restart

# add to monitoring