dep 'node.src' do
  src 'node' do
    source "http://nodejs.org/dist/node-v0.1.102.tar.gz"
    provides 'node'
  end
end
