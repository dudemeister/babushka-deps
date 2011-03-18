dep 'graphicsmagick.managed' do
  provides 'gm'
end

dep 'graphicsmagick.src' do
  source 'http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.12/GraphicsMagick-1.3.12.tar.gz/download'
  provides 'gm'
end

dep 'graphicsmagick complete' do
  requires 'tiff.src', 'freetype.src', 'libtiff.src', 'libpng.src', 'graphicsmagick.src'
end

dep 'tiff.src' do
  source 'http://download.osgeo.org/libtiff/tiff-3.9.4.tar.gz'
  provides []
end

dep 'freetype.src' do
  source 'http://download.savannah.gnu.org/releases/freetype/freetype-2.4.4.tar.gz'
  provides []
end

dep 'libjpeg.src' do
  source 'http://www.ijg.org/files/jpegsrc.v8c.tar.gz'
  provides []
end

# http://www.libpng.org/pub/png/libpng.html
dep 'libpng.src' do
  source 'http://prdownloads.sourceforge.net/libpng/libpng-1.5.1.tar.gz?download'
  provides []
end

