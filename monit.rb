dep 'monit', :template => 'managed'

dep "autostart monit" do
  met? { !grep(/^[^#]*startup=0/, "/etc/default/monit") && File.exists?("/etc/init/monit.conf") }
  meet {
    change_line "startup=0", "startup=1", "/etc/default/monit"
    unless(File.exists?("/etc/init/monit.conf"))
      render_erb 'monit/monit.erb', :to => '/etc/init/monit.conf', :sudo => true
    end
  } 
end