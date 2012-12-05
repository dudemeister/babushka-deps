dep 'cups.complete' do
end

dep 'cups.managed' do
  provides []
end

dep 'cups.src' do
  source 'http://ftp.easysw.com/pub/cups/1.5.0/cups-1.5.0-source.tar.gz'
  preconfigure { shell("cp -R ~/.babushka/build/cups-1.5.0-source/cups-1.5.0/* ~/.babushka/build/cups-1.5.0-source/; rm -rf ~/.babushka/build/cups-1.5.0-source/cups-1.5.0") }
  install { sudo("make install") }
  provides ['cups-config']
end