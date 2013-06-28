require "git_team_stats/version"
require "git_team_stats/git_parse"

module GitTeamStats

  @project = nil

  @inspected = false

  def self.start(project)
    @project = project
    
    @commits_in_detail = []

    @project[:parsers] = []
    
    @project[:repos].each do |repo|
      @project[:parsers].push(
        GitParse.new(repo)
      )
    end

  end

  def self.count_commits
    count = 0
    
    @project[:parsers].each do |parser|
      count += parser.count_commits()
    end

    return count
  end

  def self.collect_commits
    unless @inspected

      @project[:parsers].each do |parser|
        parser.get_commits()
      end
    end
  end

  def self.inspect_commits
    unless @inspected

      self.collect_commits()

      @project[:parsers].each do |parser|
        @commits_in_detail += parser.get_commit_details()
      end

      @inspected = true
    end
  end

  def self.team_cumulative_stats
    self.inspect_commits()
    
    team_cumulative = {
      :commits => 0,
      :lines => 0,
      :edits => 0,
      :file_types => {}
    }
    @commits_in_detail.each do |commit|
      team_cumulative[:commits] += 1
      team_cumulative[:lines] += commit[:lines]
      team_cumulative[:edits] += commit[:edits]

      commit[:file_types].each do |language, details|
        if team_cumulative[:file_types].key? language
          team_cumulative[:file_types][language][:lines] += details[:lines]
          team_cumulative[:file_types][language][:edits] += details[:edits]
        else
          team_cumulative[:file_types][language] = {
            :lines => details[:lines],
            :edits => details[:edits]
          }
        end
      end
    end

    return team_cumulative
  end

  def self.user_cumulative_stats(user)
    self.inspect_commits()
    
    user_cumulative = {
      :commits => 0,
      :lines => 0,
      :edits => 0,
      :file_types => {}
    }
    @commits_in_detail.each do |commit|
      if user[:aliases].any?{ |name| name == commit[:committer] }
        user_cumulative[:commits] += 1
        user_cumulative[:lines] += commit[:lines]
        user_cumulative[:edits] += commit[:edits]

        commit[:file_types].each do |language, details|
          if user_cumulative[:file_types].key? language
            user_cumulative[:file_types][language][:lines] += details[:lines]
            user_cumulative[:file_types][language][:edits] += details[:edits]
          else
            user_cumulative[:file_types][language] = {
              :lines => details[:lines],
              :edits => details[:edits]
            }
          end
        end
      end
    end

    return user_cumulative
  end

  def self.get_cache_output
    return @commits_in_detail
  end

  def self.load_from_cache(data)
    @commits_in_detail = data
    @inspected = true
  end

  def self.get_cache_file_name
    hash_str = ""
    @project[:parsers].each{ |parser|
      hash_str += parser.get_head_short_hash().to_s + "-"
    }

    return $project[:name].to_s + "-" + hash_str + @project[:start_date].to_s + '-' + @project[:end_date].to_s
  end


end
