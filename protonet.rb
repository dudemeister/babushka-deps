dep 'protonet babushka' do
  requires "fix babushka version", "sbin in path" # needed so the next script starts off with the right paths
  def version_string
    "/#{ENV["RELEASE_VERSION"]}" if ENV["RELEASE_VERSION"]
  end
  setup {
    define_var :license_key, :message => "Please enter your protonet license key"
  }
  met? { 
    File.exists?('/home/protonet/.babushka/sources/protonet/base.rb')
  }
  meet {
    cd "/tmp" do
      log_shell "cleaning   ", "rm -f babushka.tar.gz; rm -rf babushka"
      log_shell "downloading", "wget -O babushka.tar.gz http://releases.protonet.info/release/babushka/get/#{var :license_key}#{version_string}"
      if File.exists?("babushka.tar.gz")
        log_shell "unpacking  ", "tar xzf babushka.tar.gz"
        log_shell "moving     ", "mv -f babushka ~/.babushka/sources; mv -f ~/.babushka/sources/babushka ~/.babushka/sources/protonet"
      end
    end
  }
end

dep 'dudemeister deps' do
  def version_string
    "/#{ENV["RELEASE_VERSION"]}" if ENV["RELEASE_VERSION"]
  end
  setup {
    define_var :license_key, :message => "Please enter your protonet license key"
  }
  met? { 
    File.exists?('/home/protonet/.babushka/sources/dudemeister/protonet.rb')
  }
  meet {
    cd "/tmp" do
      log_shell "cleaning   ", "rm -f babushka_deps.tar.gz; rm -rf babushka-deps"
      log_shell "downloading", "wget -O babushka_deps.tar.gz http://releases.protonet.info/release/babushka-deps/get/#{var :license_key}#{version_string}"
      if File.exists?("babushka_deps.tar.gz")
        log_shell "unpacking  ", "tar xzf babushka_deps.tar.gz"
        log_shell "moving     ", "mv -f babushka-deps ~/.babushka/sources; mv -f ~/.babushka/sources/babushka-deps ~/.babushka/sources/dudemeister"
      end
    end
  }
end

dep 'dudemeister deps remove' do
  met? {
    !File.exists?('/home/protonet/.babushka/sources/dudemeister/protonet.rb')
  }
  meet {
    shell "rm -rf '/home/protonet/.babushka/sources/dudemeister'"
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
  requires 'protonet babushka remove', 'protonet babushka', 'dudemeister deps remove', 'dudemeister deps'
end

dep 'fix babushka version' do
  
  def fixed_version
    "6273012f40a880fec223921a1ea0285bf9950335"
  end
  
  met? {
    login_shell("export GIT_DIR=#{Babushka::Path.path}/.git; git show", :sudo => true).split("\n").first.match(" (.*)$")[1] == fixed_version
  }
  meet {
    login_shell("cd #{Babushka::Path.path}; git checkout master; git reset --hard; git pull origin master; git reset --hard #{fixed_version}", 
      :sudo => true)
  }
end

# https://bugs.launchpad.net/ubuntu/+source/ifupdown/+bug/512253
# wget http://gb.archive.ubuntu.com/ubuntu/pool/main/i/ifupdown/ifupdown_0.6.10ubuntu3.1_amd64.deb
# sudo dpkg --install ifupdown_0.6.10ubuntu3.1_amd64.deb