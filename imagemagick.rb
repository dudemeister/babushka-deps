dep 'imagemagick' do
  requires 'pkg libmagickwand-dev' 'pkg imagemagick'
end

pkg 'pkg libmagickwand-dev' do
  installs {
    via :apt, 'libmagickwand-dev'
  }
  provides []
end

pkg 'pkg imagemagick' do
  installs {
    via :apt, 'imagemagick'
  }
  provides 'identify'
end
