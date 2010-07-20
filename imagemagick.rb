dep 'imagemagick' do
  requires 'pkg imagemagick'
end

dep 'libmagickwand-dev', :template => 'managed' do
  installs {
    via :apt, 'libmagickwand-dev'
  }
  provides []
end

dep 'imagemagick', :template => 'managed' do
  requires 'pkg libmagickwand-dev'
  
  installs {
    via :apt, 'imagemagick'
  }
  
  provides 'identify'
end
