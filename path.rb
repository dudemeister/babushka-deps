dep "sbin in path" do
  met? {
    shell("source ~/.profile; echo $PATH").split(':').include?("/usr/sbin") &&
    shell("source ~/.profile; echo $PATH").split(':').include?("/sbin")
  }
  meet {
    append_to_file_with_section("export PATH=/sbin:/usr/sbin:$PATH", "~/.profile", "sbin PATHs")
  }
end