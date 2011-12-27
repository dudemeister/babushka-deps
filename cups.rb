dep 'cups.complete' do
  
end

dep 'cups.src' do
  source 'http://ftp.easysw.com/pub/cups/1.5.0/cups-1.5.0-source.tar.bz2'
  provides ['cups-config']
end