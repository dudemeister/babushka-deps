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
    cd "/tmp" do
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
end

dep 'fix babushka version' do
  
  def fixed_version
    "188fc73005f92d3c585527215d30e6e90ffa7c41"
  end
  
  met? {
    shell("cd #{Babushka::Path.path}; git show").split("\n").first.match(" (.*)$")[1] == fixed_version
  }
  meet {
    shell("cd #{Babushka::Path.path}; git checkout master; git reset --hard; git pull origin master; git reset --hard #{fixed_version}")
  }
end

# https://bugs.launchpad.net/ubuntu/+source/ifupdown/+bug/512253
# wget http://gb.archive.ubuntu.com/ubuntu/pool/main/i/ifupdown/ifupdown_0.6.10ubuntu3.1_amd64.deb
# sudo dpkg --install ifupdown_0.6.10ubuntu3.1_amd64.deb