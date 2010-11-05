dep "libossp-uuid16.managed" do
  provides []
end

dep "libossp-uuid-dev.managed" do
  provides ['uuid-config']
end

dep "uuid.managed" do
  provides ['uuid']
end

dep "uuid4r" do
  requires "libossp-uuid16.managed", "libossp-uuid-dev.managed", "uuid.managed"
  met? {
    failable_shell("ruby -r rubygems -e \"require 'uuid4r';UUID4R::uuid(1)\"").stderr.empty?
  }
  meet {
    in_dir('/tmp') { |path|
      log_shell "clean up...", "rm -rf uuid4r"
      log_shell "getting uuid4r from github", "git clone http://github.com/skaes/uuid4r.git", {:spinner => true}
      in_dir('uuid4r/ext') { |path|
        log_shell "configure ", "ruby extconf.rb"
        log_shell "cleaning",   "make clean"
        log_shell "making    ", "make", {:spinner => true}
        log_shell "installing", "make install", {:spinner => true, :sudo => true}
      }
    }
  }
end
