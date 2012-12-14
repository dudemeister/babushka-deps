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
    sudo("rm -f /ptn_precise-ne")
    sudo("screen -d -m -S precise && sleep 3", :su => true)
    sudo("screen -S precise -X stuff 'do-release-upgrade -d -f DistUpgradeViewNonInteractive && echo $? > /tmp/ptn_precise`echo -ne '\015'`'", :as => "root -l", :su => true)
    while !File.exist?("/tmp/ptn_precise-ne")
      sleep 10
    end
  }
end
