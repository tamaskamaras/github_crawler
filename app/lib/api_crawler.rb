class ApiCrawler

  attr_reader :user, :repo, :github_client

  def initialize attributes
    @user 				 = attributes[:user]
    @repo 				 = attributes[:repo]
    @github_client = Github.new(basic_auth: "#{attributes[:login]}:#{attributes[:password]}")
  end

  def filtered_pull_request
    result = {}
    pull_requests do |pull_request|
      file_attributes = {}
      pull_request_files(pull_request['number']) do |file|
        file_path = file['filepath']
        (file_attributes[file_path] || file_attributes[file_path] = {
          blob_url: file['blob_url'],
          line_ranges:  []
        })[:line_ranges].concat( patchs_to_ranges( file['patch'] ) )
      end
      if file_urls = redundant_file_urls(file_attributes)
        result.merge({ [ pull_request['url'] ] => file_urls })
      end
    end
    result
  end

  def pull_requests
    github_client.pull_requests.list(user: user, repo: repo) do |pull_request|
      yield(pull_request)
    end
  end

  def pull_request_files pull_request_number
    github_client.pull_requests.files(
      user:   user,
      repo:   repo,
      number: pull_request_number
    ).each do |file|
      yield(file)
    end
  end

  def patchs_to_ranges patches
    patches.split(%r{@@ -}).map do |patch|
      if raw_range = patch[/\A\d+,\d+/]&.split(',')
        start = raw_range[0].to_i
        Range.new(start, start + raw_range[1].to_i)
      end
    end.compact
  end

  def redundant_file_urls file_attributes
    file_attributes.inject([]) do |file_urls, (file_path, attributes)|
      file_urls << attributes[:blob_url] if overlap_ranges( attributes[:line_ranges] )
      file_urls
    end
  end

  def overlap_ranges ranges
    ranges.inject([]) do |line_ranges, line_range|
    end if ranges.length > 1
  end

end
