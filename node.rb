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
    system("nvm")
  }
  meet {
    log_shell "installing nvm", "curl https://raw.github.com/creationix/nvm/master/install.sh | sh"
  }
end

dep 'nvm node0101' do
  requires 'nvm'
  met? {
    `node -v`.strip == 'v0.10.1'
  }
  meet {
    sudo "source /home/protonet/.nvm/nvm.sh; nvm install 0.10.1", as: 'protonet'
  }
end
