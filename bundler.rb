gem 'bundler' do
  requires 'rdoc'
  installs 'bundler' => '0.9.25'
  provides 'bundle'
end

gem 'rdoc' do
  installs 'rdoc'
  provides 'rdoc'
end
