class CrawlerController < ApplicationController

	def index
		result = ApiCrawler.new(
      user:     params[:user],
      repo:     params[:repo],
      login:    params[:login],
      password: params[:password]
    ).filtered_pull_request
    render json: { redundancy: result }
	end

  def filter_params
    params.expect(:user, :repo, :login, :password)
  end

end
