dep 'python-xattr.managed' do
  provides 'xattr'
end

dep 'enable xattr' do
  met? {
    !!sudo("mount").match("user_xattr")
  }
  
  meet {
    needle = Regexp.escape("errors=remount-ro")
    replacement = "errors=remount-ro,user_xattr"
    sudo("sed -i '' -e 's/#{needle}/#{replacement}/' '/etc/fstab'")
    sudo("mount -o remount,user_xattr /")
  }
end