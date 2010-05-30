dep 'imagemagick' do
  requires 'pkg libmagickwand-dev'
end

pkg 'pkg libmagickwand-dev' do
  installs {
    via :apt, 'libmagickwand-dev'
  }
  provides 'identify'
end
