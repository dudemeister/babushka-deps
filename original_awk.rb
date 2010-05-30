dep 'original-awk' do
  requires 'pkg original-awk'
end

pkg 'pkg original-awk' do
  installs {
    via :apt, 'original-awk'
  }
  provides 'original-awk'
end
