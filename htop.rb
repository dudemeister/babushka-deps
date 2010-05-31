dep 'htop' do
  requires 'pkg htop'
end

pkg 'pkg htop' do
  installs {
    via :apt, 'htop'
  }
  provides 'htop'
end
