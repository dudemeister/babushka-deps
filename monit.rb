dep 'monit', :template => 'managed'

dep "autostart monit" do
  met? { !grep(/^[^#]*startup=0/, "/etc/default/monit") && File.exists?("/etc/event.d/monit") }
  meet {
    change_line "startup=0", "startup=1", "/etc/default/monit"
    unless(File.exists?("/etc/event.d/monit"))
      render_erb 'monit/monit.erb', :to => '/etc/event.d/monit/monit', :sudo => true
    end
  } 
end