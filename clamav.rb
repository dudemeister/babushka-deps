dep 'clamav.managed' do
  after { sudo('freshclam') }
end