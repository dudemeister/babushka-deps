dep 'node.src' do
  source "http://nodejs.org/dist/v0.6.5/node-v0.6.5.tar.gz"
  provides 'node', 'node-waf'
end

dep 'npm update' do
  met? { shell('npm --version').to_i > 1.1 }
  meet { shell('npm update npm -g')        }
end

dep 'node066.src' do
  source "http://nodejs.org/dist/v0.6.6/node-v0.6.6.tar.gz"
  provides 'node', 'node-waf'
end
