dep 'htop', :template => 'managed' do
  installs {
    via :apt, 'htop'
  }
  provides 'htop'
end