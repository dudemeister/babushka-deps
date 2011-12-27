dep 'mdns.managed' do
  installs {
    via :apt, 'avahi-daemon'
  }
  provides []
end

dep "mdns-scan.managed"
dep "avahi-utils.managed"
dep "libavahi-common-dev.managed"
dep "libavahi-compat-libdnssd1.managed"
dep "libavahi-compat-libdnssd-dev.managed"

dep "mdns.complete"
  requires "mdns.managed", "mdns-scan.managed", "avahi-utils.managed", "libavahi-common-dev.managed", "libavahi-compat-libdnssd1.managed", "libavahi-compat-libdnssd-dev.managed"
end
