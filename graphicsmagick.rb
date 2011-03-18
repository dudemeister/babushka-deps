dep 'graphicsmagick.managed' do
  provides 'gm'
end

dep 'graphicsmagick.src' do
  source 'http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.12/GraphicsMagick-1.3.12.tar.gz/download'
  provides 'gm'
end

dep 'graphicsmagick complete' do
  requires 'tiff.managed', 'libjpeg6b.managed', 'libpng.managed', 'graphicsmagick.src'
end

dep 'tiff.managed' do
  provides []
end

dep 'libjpeg6b.managed' do
  provides []
end

dep 'libpng.managed' do
  provides []
end

