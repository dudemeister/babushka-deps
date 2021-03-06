def ssh_conf_path file
  "/etc#{'/ssh' if Babushka::Base.host.linux?}/#{file}_config"
end

dep 'hostname', :for => :linux do
  def hostname
    shell 'hostname'
  end
  met? {
    stored_hostname = '/etc/hostname'.p.read
    !stored_hostname.blank? && hostname == stored_hostname
  }
  meet {
    sudo "echo #{var :hostname, :default => shell('hostname')} > /etc/hostname"
    sudo "hostname #{var :hostname}"
  }
end

dep 'hosts', :for => :linux do
  def hostname
    shell 'hostname -f'
  end
  
  met? { 
    grep 'protonet', '/etc/hosts' 
  }
  meet {
    sudo "sed -ri 's/^127.0.0.1.*$/127.0.0.1 #{hostname} #{hostname.sub(/\..*$/, '')} protonet localhost.localdomain localhost/' /etc/hosts"
  }
end

dep 'secured ssh logins' do
  requires 'sshd.managed', 'sed.managed'
  met? {
    # -o NumberOfPasswordPrompts=0
    output = raw_shell('ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no nonexistentuser@localhost').stderr
    if output.downcase['connection refused']
      log_ok "sshd doesn't seem to be running."
    elsif (auth_methods = output.scan(/Permission denied \((.*)\)\./).join.split(/[^a-z]+/)).empty?
      log_error "sshd returned unexpected output."
    else
      (auth_methods == %w[publickey]).tap {|result|
        log_verbose "sshd #{'only ' if result}accepts #{auth_methods.to_list} logins.", :as => (result ? :ok : :error)
      }
    end
  }
  meet {
    change_with_sed 'PasswordAuthentication',          'yes', 'no', ssh_conf_path(:sshd)
    change_with_sed 'ChallengeResponseAuthentication', 'yes', 'no', ssh_conf_path(:sshd)
  }
  after { sudo "/etc/init.d/ssh restart" }
end

dep 'lax host key checking' do
  requires 'sed.managed'
  met? { grep /^StrictHostKeyChecking[ \t]+no/, ssh_conf_path(:ssh) }
  meet { change_with_sed 'StrictHostKeyChecking', 'yes', 'no', ssh_conf_path(:ssh) }
end

dep 'admins can sudo' do
  requires 'admin group'
  met? { !sudo('cat /etc/sudoers').split("\n").grep(/^%admin/).empty? }
  meet { append_to_file '%admin  ALL=(ALL) ALL', '/etc/sudoers', :sudo => true }
end

dep 'admin group' do
  met? { grep /^admin\:/, '/etc/group' }
  meet { sudo 'groupadd admin' }
end

dep 'tmp cleaning grace period', :for => :ubuntu do
  met? { !grep(/^[^#]*TMPTIME=0/, "/etc/default/rcS") }
  meet { change_line "TMPTIME=0", "TMPTIME=30", "/etc/default/rcS" }
end
