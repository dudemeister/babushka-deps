dep 'bundler_pre' do
  met? { 
    login_shell('which bundle') && 
      login_shell('bundle -v')['Bundler version 1.2.0.pre']
  }
  meet {
    login_shell("gem install bundler --pre")
  }
end

dep 'bundler', :template => 'gem' do
  requires 'rdoc'
  installs 'bundler = 1.0.11'
  provides 'bundle'
end

dep 'bundler_1_0_11', :template => 'gem' do
  requires 'rdoc'
  installs 'bundler = 1.0.11'
  provides 'bundle'
end

dep 'rdoc', :template => 'gem' do
  installs 'rdoc'
  provides 'rdoc'
end

dep 'app bundled' do
  requires 'deployed app', 'bundler.gem', 'db gem'
  met? { cd(var(:rails_root)) { shell 'bundle check', :log => true } }
  meet { 
    cd(var(:rails_root)) {
      install_args = var(:rails_env) != 'production' ? '' : "--deployment --without 'development test'"
      unless shell("bundle install #{install_args}", :log => true)
        confirm("Try a `bundle update`") {
          shell 'bundle update', :log => true
        }
      end
    }
  }
end

dep 'deployed app' do
  met? { File.directory? var(:rails_root) / 'app' }
end
