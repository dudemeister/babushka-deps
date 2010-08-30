dep 'monit', :template => 'managed'

dep "autostart monit" do
  met? { !grep(/^[^#]*startup=0/, "/etc/default/monit") }
  meet { change_line "startup=0", "startup=1", "/etc/default/monit" } 
end