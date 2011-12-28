dep 'mdns.managed' do
  installs {
    via :apt, 'avahi-daemon'
  }
  provides []
end

dep "mdns-scan.managed"
dep "avahi-utils.managed" do
  provides ['avahi-browse', 'avahi-publish', 'avahi-resolve']
end
dep "libavahi-common-dev.managed" do
  provides []
end
dep "libavahi-compat-libdnssd1.managed" do
  provides []
end
dep "libavahi-compat-libdnssd-dev.managed" do
  provides []
end

dep "mdns.complete" do
  requires "mdns.managed", "mdns-scan.managed", "avahi-utils.managed", "libavahi-common-dev.managed", "libavahi-compat-libdnssd1.managed", "libavahi-compat-libdnssd-dev.managed"
end
