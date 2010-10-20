dep "uuid" do
  met? {
    which 'uuid'
  }
  meet {
    in_dir('/tmp') { |path|
      uuid_version = "uuid-1.6.2"
      log_shell "downloading ossp uuid", "curl -LO ftp://ftp.ossp.org/pkg/lib/uuid/#{uuid_version}.tar.gz", {:spinner => true}
      log_shell "expanding   ossp uuid", "tar xzf #{uuid_version}.tar.gz", {:spinner => true}
      in_dir(uuid_version) { |path|
        log_shell "configure ", "./configure"
        log_shell "making    ", "make", {:spinner => true}
        log_shell "installing", "make install", {:spinner => true, :sudo => true}
      }
    }
  }
end

dep "uuid4r" do
  requires 'uuid'
  met? {
    failable_shell("ruby -e \"require 'uuid4r';UUID4R::uuid(1)\"").stderr.empty?
  }
  meet {
    in_dir('/tmp') { |path|
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
