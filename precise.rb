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
    sudo("do-release-upgrade -d -f DistUpgradeViewNonInteractive > /home/protonet/.babushka/logs/ptn_ubuntu_update")
  }
end