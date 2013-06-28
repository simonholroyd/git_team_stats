require 'progress_bar'
require 'rainbow'
require 'language_sniffer'

class GitParse


  def initialize(directory)
    @commits = []

    @ignored_directories = []
    @start_date = nil
    @end_date = nil
    
    @directory = directory
  end


  def execute(command, directory = ".")
    directory = `cd #{directory}; #{command}`
  end


  def get_commits

    hash = ""

    puts "finding commits in #{@directory}".color(:yellow)
    rev_list = get_rev_list()
    bar = ProgressBar.new(rev_list.lines.length, :bar, :percentage, :eta);
    rev_list.lines.each do |line|
      bar.increment!
      if ( line =~ /^commit ([\w]+)/)
          hash = $1
          next
      else hash != ""
          if ( line =~ /^([\d]+)\s(.+)\s<(.+)>$/ )
              timestamp = $1.to_i
              committer = $2
              email = $3
          end
      
          @commits.push({
              :hash => hash,
              :committer => committer,
              :path => @directory,
              :timestamp => timestamp,
          })

          hash = ""
      end
    end

    return @commits
  end



  def count_commits
    if @commits.empty?
      get_commits()
    end

    return @commits.count
  end

  def get_authors
    users = []
    get_authors_from_shortlog().lines.each do |line|
      if !users.any? {|user| user[:name] = line }
        users.push({
          :name => line.strip,
          :aliases => [line.strip]
        })
      end
    end
    return users
  end

  def get_authors_from_shortlog
    return execute("git shortlog -s | cut -c8-", @directory)
  end

  def get_head_short_hash
    return execute("git rev-parse --short HEAD", @directory).strip
  end

  def get_rev_list
    date_str = ""
    if @start_date != nil
      date_str += "--max-age=%s " % [@start_date.to_i.to_s]
    end
    if @end_date != nil
      date_str += "--min-age=%s " % [@end_date.to_i.to_s]
    end
    return execute("git rev-list --reverse --pretty=format:\"%%at %%aN <%%aE>\" %s HEAD" % date_str, @directory)
  end

  def get_diff_tree(commit_hash)
    return execute("git diff-tree %s --numstat" % commit_hash, @directory)
  end

  def get_file(commit_hash, file_name)
    return execute("git show %s:%s 2>&1" % [commit_hash, file_name], @directory)
  end

  def parse_diff_tree(commit_hash)

    total_lines = 0
    total_edits = 0
    file_types = {}

    diff_tree = get_diff_tree(commit_hash)

    diff_tree.lines.each do |line|
      
      if ( line =~ /^([\d]+)\s([\d]+)(.*[^\w](\w+))$/)

        insertions = $1.to_i
        deletions = $2.to_i

        lines = insertions - deletions
        edits = insertions + deletions

        file_name = $3.strip!

        extension = $4
        
        if (@ignored_directories.any?{ |obj| (file_name.index(obj) == 0) })
          next
        end
        
        language = get_language_for_file(file_name, commit_hash)

        if language == nil
          next
        end

        if (file_types.key? language.name.to_sym)
          file_types[language.name.to_sym][:lines] += lines
          file_types[language.name.to_sym][:edits] += edits
        else
          file_types[language.name.to_sym] = {
            :lines => lines,
            :edits => edits
          }
        end

        total_lines += lines
        total_edits += edits


      end
    end

    return {
        :lines => total_lines,
        :edits => total_edits,
        :file_types => file_types
    }

  end

  def get_language_for_file(file_name, commit_hash)
    escaped_file_name = file_name.gsub(/([\[\(\)\]\{\}\*\?\\])/, '\\\\\1')

    full_file_path = File.join(Dir.home, @directory.gsub(/^~/, ""), file_name)

    if File.file? full_file_path
      language = LanguageSniffer.detect(full_file_path).language;
    else 
      language = LanguageSniffer.detect(full_file_path, :content => get_file(commit_hash, escaped_file_name), :path => full_file_path).language;
    end

    return language
  end

  def get_commit_details

    puts "analyzing commits in #{@directory}".color(:yellow)
    
    bar = ProgressBar.new(@commits.length, :bar, :percentage, :eta);

    @commits.each { |commit|
      
      bar.increment!

      diff_tree = parse_diff_tree(commit[:hash])

      commit.merge!(diff_tree)
    }

    return @commits

  end

end
