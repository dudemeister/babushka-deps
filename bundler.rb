dep 'bundler', :template => 'gem' do
  requires 'rdoc'
  installs 'bundler' => '0.9.26'
  provides 'bundle'
end

dep 'rdoc', :template => 'gem' do
  installs 'rdoc'
  provides 'rdoc'
end

dep 'app bundled' do
  requires 'deployed app', 'bundler.gem', 'db gem'
  met? { in_dir(var(:rails_root)) { shell 'bundle check', :log => true } }
  meet { in_dir(var(:rails_root)) {
    install_args = var(:rails_env) != 'production' ? '' : "--deployment --without 'development test'"
    unless shell("bundle install #{install_args}", :log => true)
      confirm("Try a `bundle update`") {
        shell 'bundle update', :log => true
      }
    end
  } }
end

dep 'deployed app' do
  met? { File.directory? var(:rails_root) / 'app' }
end
