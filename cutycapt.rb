dep 'cutycapt' do
  requires "git", "libqt4-webkit.managed", "libqt4-dev", "g++.managed"
  met? { which("CutyCapt") }
  meet {
    in_dir "/tmp" do
      log_shell "cleaning   ", "rm -rf cutycapt"
      log_shell "downloading", "git clone https://github.com/jdecuyper/cutycapt.git"
      if File.exists?("cutycapt")
        in_dir "cutycapt/CutyCapt" do
          log_shell "qmake      ", "qmake"
          log_shell "make       ", "make"
          log_shell "copy       ", "cp CutyCapt /usr/local/bin"
        end
      end
    end
  }
end

dep "libqt4-webkit.managed" do
  provides []
end
dep "libqt4-dev.managed" do
  provides []
end
dep "g++.managed"