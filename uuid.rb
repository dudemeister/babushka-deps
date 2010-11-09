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
    log_shell "installing gem", "gem install dudemeister-uuid4r -v 0.1.2 --no-rdoc --no-ri", {:spinner => true, :sudo => true}
  }
end
