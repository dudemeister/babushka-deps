dep 'clamav' do
  requires 'clamav.managed'
  after { sudo 'freshclam' }
end

dep 'clamav.managed' do
  installs { via :apt, 'clamav' }
  provides []
end