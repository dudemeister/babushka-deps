dep 'sqlite3' do
  requires 'pkg sqlite3'
end

pkg 'pkg sqlite3' do
  installs {
    via :apt, 'sqlite3'
  }
  provides 'sqlite3'
end
