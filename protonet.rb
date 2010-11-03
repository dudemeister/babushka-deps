dep 'protonet babushka' do
  setup {
    define_var :deploy_key, :message => "Please enter your protonet license key"
  }
  met? { 
    File.exists?('/home/protonet/.babushka/sources/protonet/base.rb')
  }
  meet {
    in_dir "/tmp" do
      log_shell "cleaning   ", "rm babushka.tar.gz; rm -rf babushka"
      log_shell "downloading", "wget -O babushka.tar.gz http://releases.protonet.info/release/babushka/get/#{var :deploy_key}"
      if File.exists?("babushka.tar.gz")
        log_shell "unpacking  ", "tar xzf babushka.tar.gz"
        log_shell "moving     ", "mkdir -p ~/.babushka/sources/protonet; mv babushka ~/.babushka/sources/protonet"
      end
    end
  }
end