dep 'precise' do
  requires  'precise.update', 
            'protonet:add defaults tty_tickets to sudoers',
            'monit.link',
            'passenger.deinstall',
            'passenger',
            'prepare apache2 envvars for precise',
            'apache2 passenger mods configured',
            'libjpeg62.managed'
end

dep 'precise.update' do
  met?{
    Babushka::SystemProfile.for_host.name == :precise
  }
  meet{ 
    sudo("rm -f /tmp/ptn_precise")
    sudo("screen -d -m -S precise", :su => true)
    sudo("screen -S precise -p 0 -X stuff 'do-release-upgrade -m server -f DistUpgradeViewNonInteractive && echo $? > /tmp/ptn_precise'", :as => "root", :su => true)
    sudo("screen -S precise -p 0 -X stuff 'echo \015'", :as => "root", :su => true)
    while !File.exist?("/tmp/ptn_precise")
      sleep 10
    end
  }
end
