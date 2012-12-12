dep 'precise' do
  requires  'precise.update', 
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
    sudo("do-release-upgrade -d -f DistUpgradeViewNonInteractive")
  }
end