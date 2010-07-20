dep 'bundler', :template => 'gem' do
  requires 'rdoc'
  installs 'bundler' => '0.9.25'
  provides 'bundle'
end

dep 'rdoc', :template => 'gem' do
  installs 'rdoc'
  provides 'rdoc'
end
