dep 'samba' do
  requires 'samba.managed'
  met? do
    babushka_config? "/etc/samba/smb.conf"
  end
  meet do
    render_erb "samba/smb.conf.erb", :to => "/etc/samba/smb.conf", :sudo => true
  end
end

dep 'samba.managed' do
  installs { via :apt, 'samba' }
  provides []
  before do
    shell("echo manual > /etc/init/smbd.override", :sudo => true)
    shell("echo manual > /etc/init/nmbd.override", :sudo => true)
  end
end
