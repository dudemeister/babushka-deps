dep 'graphicsmagick.managed' do
  provides 'gm'
end

dep 'graphicsmagick.src' do
  source 'http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.12/GraphicsMagick-1.3.12.tar.gz/download'
  provides 'gm'
end
