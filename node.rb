dep 'node.src' do
  source "http://nodejs.org/dist/v0.6.5/node-v0.6.5.tar.gz"
  provides 'node', 'node-waf'
end

dep 'node066.src' do
  source "http://nodejs.org/dist/v0.6.6/node-v0.6.6.tar.gz"
  provides 'node', 'node-waf'
end

dep 'nvm' do
  met? {
    login_shell('nvm help | grep \"Node Version Manager\"', as: "protonet") == 'Node Version Manager'
  }
  meet {
    log_shell "installing nvm", "curl https://raw.github.com/creationix/nvm/master/install.sh | sh"
  }
end

dep 'nvm node0101' do
  requires 'nvm'
  met? {
    login_shell(". /home/protonet/.nvm/nvm.sh; node -v | grep v0.10.1", as: "protonet") == 'v0.10.1'
  }
  meet {
    login_shell('. /home/protonet/.nvm/nvm.sh; nvm install 0.10.1; nvm alias default 0.10.1', as: "protonet")
  }
end
