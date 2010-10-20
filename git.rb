dep 'git-aliases' do
  requires 'git'
  met? { 
    met_result = false
    tmp_path = "/tmp/git-aliases-test"
    shell("mkdir #{tmp_path}; cd #{tmp_path}; git init; touch foo")
    in_dir(tmp_path) do
      met_result = ["git st", "git br", "git add .; git ci -am 'foo'", "git co ."].all? do |alias_check|
        failable_shell(alias_check).stderr.empty?
      end
    end
    system("rm -rf #{tmp_path}")
    met_result
  }
  meet {
    log_shell "Adding git alias ci for commit",   "git config --global alias.ci commit"
    log_shell "Adding git alias co for checkout", "git config --global alias.co checkout"
    log_shell "Adding git alias br for branch",   "git config --global alias.br branch"
    log_shell "Adding git alias st for status",   "git config --global alias.st status"
  }
end

dep 'passenger deploy repo' do
  requires 'passenger deploy repo exists', 'passenger deploy repo hooks', 'passenger deploy repo always receives'
end

dep 'passenger deploy repo always receives' do
  requires 'passenger deploy repo exists'
  met? { in_dir(var(:passenger_repo_root)) { shell("git config receive.denyCurrentBranch") == 'ignore' } }
  meet { in_dir(var(:passenger_repo_root)) { shell("git config receive.denyCurrentBranch ignore") } }
end

dep 'passenger deploy repo hooks' do
  requires 'passenger deploy repo exists'
  met? {
    %w[pre-receive post-receive].all? {|hook_name|
      (var(:passenger_repo_root) / ".git/hooks/#{hook_name}").executable?
    }
  }
  meet {
    in_dir var(:passenger_repo_root), :create => true do
      %w[pre-receive post-receive].each {|hook_name|
        render_erb "git/deploy-repo-#{hook_name}", :to => ".git/hooks/#{hook_name}"
        shell "chmod +x .git/hooks/#{hook_name}"
      }
    end
  }
end

dep 'passenger deploy repo exists' do
  requires 'git'
  define_var :passenger_repo_root, :default => :rails_root
  met? { (var(:passenger_repo_root) / '.git').dir? }
  meet {
    in_dir var(:passenger_repo_root), :create => true do
      shell "git init"
    end
  }
end
