dep 'libmagickwand-dev', :template => 'managed' do
  provides []
end

dep 'imagemagick', :template => 'managed' do
  provides 'identify'
end

dep 'imagemagick complete' do
  requires 'libmagickwand-dev'
  requires 'imagemagick'
end
