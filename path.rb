dep "sbin in path" do
  met? {
    shell(". ~/.profile; echo $PATH").split(':').include?("/usr/sbin") &&
    shell(". ~/.profile; echo $PATH").split(':').include?("/sbin")
  }
  meet {
    append_to_file_with_section("export PATH=/sbin:/usr/sbin:/usr/local/bin:/usr/bin:/bin:$PATH", "~/.profile", "sbin PATHs")
    # set path for this process too
    ENV["PATH"] = "/sbin:/usr/sbin:/usr/local/bin:/usr/bin:/bin:#{ENV["PATH"]}"
  }
end