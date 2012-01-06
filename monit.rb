dep 'monit', :template => 'managed'

dep 'monit.src' do
  source 'https://github.com/downloads/protonet/custom_debs/monit_5.3.2-custom_amd64.deb'
  process_source {
    sudo("dpkg -i monit_5.3.2-custom_amd64.deb")
  }
  postinstall {
    sudo("ln -s /etc/monit/monitrc /etc/monitrc")
  }
  provides ['monit']
end

dep "autostart monit" do
  met? { !grep(/^[^#]*startup=0/, "/etc/default/monit") && File.exists?("/etc/init/monit.conf") }
  meet {
    change_line "startup=0", "startup=1", "/etc/default/monit"
    # remove existing monit startscripts
    sudo("update-rc.d -f monit remove")
    unless(File.exists?("/etc/init/monit.conf"))
      render_erb 'monit/monit.erb', :to => '/etc/init/monit.conf', :sudo => true
    end
  } 
end