dep 'node.src' do
  source "http://nodejs.org/dist/node-v0.4.1.tar.gz"
  provides 'node', 'node-waf'
end