module Gitbase
  def checkout_commit(git_dir, commit)
    throw 'Git directory not found' unless File.exist?(git_dir)
    # cmd = get_cmd("cd #{git_dir};git reset --hard HEAD")
    cmd = "cd #{git_dir} && git reset --hard HEAD"
    `#{cmd}`
    # cmd = get_cmd("cd #{git_dir};git clean -f -d")
    cmd = "cd #{git_dir} && git clean -f -d"
    `#{cmd}`
    # co_cmd = get_cmd("cd #{git_dir};git checkout #{commit}")
    co_cmd = "cd #{git_dir} && git checkout #{commit}"
    stdin, stdout, stderr = Open3.popen3(co_cmd)
    @ref = nil
    while (err = stderr.gets)
      puts err unless err.include? "Already on 'master'"
      @ref = err
      next unless err =~ /Your local changes to the following files would be overwritten by checkout/
      `#{remove_command} #{git_dir}/*`
      # cmd = get_cmd("cd #{git_dir};git checkout #{co_cmd}")
      cmd = "cd #{git_dir} && git checkout #{commit}"
      `#{cmd}`
      # cmd = get_cmd("cd #{git_dir};git reset --hard HEAD")
      cmd = "cd #{git_dir} && git reset --hard HEAD"
      `#{cmd}`
      # cmd = get_cmd("cd #{git_dir};git clean -fdx")
      cmd = "cd #{git_dir} && git clean -fdx"
      `#{cmd}`
      @ref = `#{co_cmd}`
      break
    end
  end

  def git_dir?(dir)
    return false unless File.directory?("#{dir}/.git")
    cmd = "cd #{dir} && git rev-parse"
    if Gem.win_platform?
      cmd = "#{cmd} 2> nul"
    else
      cmd = "#{cmd} > /dev/null 2>&1"
    end
    system(cmd)
  end
end
