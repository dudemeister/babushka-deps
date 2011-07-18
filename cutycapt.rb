dep 'cutycapt' do
  requires "git", "libqt4-webkit.managed", "libqt4-dev.managed", "g++.managed", "xvfb.managed"
  met? { which("CutyCapt") }
  meet {
    cd "/tmp" do
      log_shell "cleaning   ", "rm -rf cutycapt"
      log_shell "downloading", "git clone https://dudemeister@github.com/dudemeister/cutycapt.git"
      if File.exists?("cutycapt")
        cd "cutycapt" do
          log_shell "qmake      ", "qmake"
          log_shell "make       ", "make"
          log_shell "copy       ", "cp CutyCapt /usr/local/bin"
        end
      end
    end
  }
end

dep "g++.managed"