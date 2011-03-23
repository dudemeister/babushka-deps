dep 'graphicsmagick.managed' do
  provides 'gm'
end

dep 'graphicsmagick-libmagick-dev-compat.managed' do
  provides []
end

dep 'graphicsmagick.src' do
  source 'http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.12/GraphicsMagick-1.3.12.tar.gz/download'
  provides 'gm'
end

dep 'graphicsmagick complete' do
  requires 'libtiff4-dev.managed', 'libjpeg62-dev.managed', 'libpng12-dev.managed', 'graphicsmagick.src'
end

dep 'libtiff4-dev.managed' do
  provides []
end

dep 'libjpeg62-dev.managed' do
  provides []
end

dep 'libpng12-dev.managed' do
  provides []
end

