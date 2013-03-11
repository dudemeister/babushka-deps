#
# The Rubies are installed with system-wide RVM now.
#

#dep 'ruby trunk.src' do
#  requires 'bison.managed', 'readline headers.managed'
#  source 'git://github.com/ruby/ruby.git'
#  provides 'ruby == 1.9.3.dev', 'gem', 'irb'
#end

#dep 'ruby19.src' do
#  requires 'readline headers.managed'
#  source 'ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p136.tar.gz'
#  provides 'ruby == 1.9.2p136', 'gem', 'irb'
#  configure_args '--disable-install-doc', '--with-readline-dir=/usr'
#  # TODO: hack for ruby bug where bin/* aren't installed when the build path
#  # contains a dot-dir.
#  postinstall {
#    shell "cp bin/* #{prefix / 'bin'}", :sudo => Babushka::SrcHelper.should_sudo?
#  }
#end

#
# Ruby 1.8 is already long past obsolete
#

#dep 'ruby1.8-dev.managed' do
#  provides []
#end

#dep 'ruby18.src' do
#  source 'ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p302.tar.gz'
#  provides 'ruby18'
#  configure_args '--program-suffix=18', '--enable-pthread'
#end

#dep 'rubygems18.src' do
#  requires 'ruby18.src'
#  provides 'gem18'
#  source 'http://rubyforge.org/frs/download.php/70696/rubygems-1.3.7.tgz'
#  process_source {
#    sudo 'ruby18 setup.rb'
#  }
#end

dep 'ruby symlinked' do
  define_var :ruby_version, :choices => %w[18 19]
  def ruby_binaries
    %w[erb gem irb rdoc ri ruby testrb rake].select {|rb|
      (prefix / "#{rb}#{var(:ruby_version)}").exists?
    }
  end
  def prefix
    '/usr/local/bin'
  end
  met? {
    ruby_binaries.all? {|rb|
      (prefix / rb).exists? &&
      (prefix / rb).readlink == (prefix / "#{rb}#{var(:ruby_version)}")
    }
  }
  meet {
    cd prefix do |path|
      ruby_binaries.each {|rb| sudo "ln -sf '#{rb}#{var(:ruby_version)}' '#{rb}'" }
    end
  }
end

dep 'rubygems_1_6_2' do
  def version; '1.6.2' end
  requires_when_unmet 'curl.managed'
  met? {
    # We check for ruby here too to make sure `ruby` and `gem` run from the same place.
    in_path? ["gem >= #{version}", 'ruby']
  }
  meet {
    handle_source "http://production.cf.rubygems.org/rubygems/rubygems-#{version}.tgz" do
      log_shell "Installing rubygems-#{version}", "ruby setup.rb", :spinner => true, :sudo => !File.writable?(which('ruby'))
    end
  }
  after {
    %w[cache ruby specs].each {|name| ('~/.gem' / name).mkdir }
    cd cmd_dir('ruby') do
      if File.exists? 'gem1.8'
        shell "ln -sf gem1.8 gem", :sudo => !File.writable?(which('ruby'))
      end
    end
  }
end

