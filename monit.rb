dep 'monit' do
  if Babushka::SystemProfile.for_host.name == :precise
    requires 'monit.managed', 'monit.link'
  else
    requires 'monit.src', 'autostart monit'
  end
end

dep 'monit.managed'

dep 'monit.src' do
  source 'https://github.com/downloads/protonet/custom_debs/monit_5.3.2-custom_v2_amd64.deb'
  process_source {
    sudo("rm -f /etc/monit/monitrc")
    sudo("ln -s /etc/monit/monitrc /etc/monitrc")
    sudo("dpkg -i --force-confnew --force-confmiss monit_5.3.2-custom_v2_amd64.deb")
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


dep "remove autostart monit" do
  requires 'monit'
  requires 'rcconf.managed'
  met? { shell("rcconf --list").val_for('monit') == 'off' }
  meet {
    sudo("update-rc.d -f monit remove")
  } 
end


dep 'monit.link' do
  met? { File.exists?("/usr/sbin/monit") }
  meet { sudo("ln -s /usr/bin/monit /usr/sbin/monit") }
end