dep "libossp-uuid-dev.managed" do
  provides ['uuid-config']
end

dep "uuid.managed" do
  provides ['uuid']
end

dep "libossp-uuid16.managed" do
  provides []
end

dep "uuid4r" do
  requires "libossp-uuid16.managed", "uuid.managed", "libossp-uuid-dev.managed"
  met? {
    failable_shell("ruby -e \"require 'uuid4r';UUID4R::uuid(1)\"").stderr.empty?
  }
  meet {
    log_shell "installing gem", "gem install fishman-uuid4r", {:spinner => true, :sudo => true}
    # in_dir('/tmp') { |path|
    #   log_shell "clean up...", "rm -rf uuid4r"
    #   log_shell "getting uuid4r from github", "git clone http://github.com/dudemeister/uuid4r.git", {:spinner => true}
    #   in_dir('uuid4r/ext') { |path|
    #     log_shell "configure ", "ruby extconf.rb"
    #     log_shell "cleaning",   "make clean"
    #     log_shell "making    ", "make", {:spinner => true}
    #     log_shell "installing", "make install", {:spinner => true, :sudo => true}
    #   }
    # }
  }
end
