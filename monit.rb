dep 'monit' do
  requires 'pkg monit'
end

pkg 'pkg monit' do
  installs {
    via :apt, 'monit'
  }
  provides 'monit'
end
