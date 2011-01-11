dep 'node.src' do
  source "http://nodejs.org/dist/node-v0.2.6.tar.gz"
  provides 'node', 'node-waf'
end
