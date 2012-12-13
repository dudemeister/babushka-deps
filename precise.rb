dep 'precise' do
  requires  'precise.update', 
            'protonet:add defaults tty_tickets to sudoers',
            'monit.link',
            'passenger.deinstall',
            'passenger',
            'prepare apache2 envvars for precise',
            'libjpeg62.managed'
end

dep 'precise.update' do
  met?{
    Babushka::SystemProfile.for_host.name == :precise
  }
  meet{
    sudo("rm -f /ptn_precise")
    sudo("screen -d -m \"do-release-upgrade -d -f DistUpgradeViewNonInteractive && echo $? > /tmp/ptn_precise\"")
    while !File.exist?("/tmp/ptn_precise")
      sleep 10
    end
  }
end