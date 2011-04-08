dep 'protonet babushka' do
  requires "fix babushka version", "sbin in path" # needed so the next script starts off with the right paths
  def version_string
    "/#{ENV["RELEASE_VERSION"]}" if ENV["RELEASE_VERSION"]
  end
  setup {
    define_var :deploy_key, :message => "Please enter your protonet license key"
  }
  met? { 
    File.exists?('/home/protonet/.babushka/sources/protonet/base.rb')
  }
  meet {
    in_dir "/tmp" do
      log_shell "cleaning   ", "rm -f babushka.tar.gz; rm -rf babushka"
      log_shell "downloading", "wget -O babushka.tar.gz http://releases.protonet.info/release/babushka/get/#{var :deploy_key}#{version_string}"
      if File.exists?("babushka.tar.gz")
        log_shell "unpacking  ", "tar xzf babushka.tar.gz"
        log_shell "moving     ", "mv babushka ~/.babushka/sources; mv ~/.babushka/sources/babushka ~/.babushka/sources/protonet"
      end
    end
  }
end

dep 'protonet babushka remove' do
  met? {
    !File.exists?('/home/protonet/.babushka/sources/protonet/base.rb')
  }
  meet {
    shell "rm -rf '/home/protonet/.babushka/sources/protonet'"
  }
end

dep 'protonet babushka update' do
  requires 'protonet babushka remove', 'protonet babushka'
  # this is added to ensure that the upcoming babuhska migration is run correctly
  if(grep('spawn babushka protonet:up.migration', "/home/protonet/dashboard/current/script/ptn_babushka_migrations"))
    text = <<-EOL
    spawn bash -l
    exp_send "/sbin/MAKEDEV pty"
    exp_send "/sbin/MAKEDEV tty"
    exp_send "source /home/protonet/.bashrc\\n"
    exp_send "source /home/protonet/.profile\\n"
    exp_send "babushka protonet:up.migration\\n"
    EOL
    change_line 'spawn babushka protonet:up.migration', text, "/home/protonet/dashboard/current/script/ptn_babushka_migrations"
  end
end

dep 'fix babushka version' do
  
  def fixed_version
    "2d1a54b2eda98d30e7d17b55e99c3ce8970d374a"
  end
  
  met? {
    shell("cd #{Babushka::Path.path}; git show").split("\n").first.match(" (.*)$")[1] == fixed_version
  }
  meet {
    shell("cd #{Babushka::Path.path}; git checkout master; git reset --hard; git pull origin master; git reset --hard #{fixed_version}")
  }
end