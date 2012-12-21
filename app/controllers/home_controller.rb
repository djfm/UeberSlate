class HomeController < ApplicationController
  def index
    @admin        = current_user.roles.find_by_name("admin") if current_user
    @resque_info  = Resque.info
    @online_users = User.find :all, :conditions => ["last_seen > ?",5.minutes.ago.to_s(:db)]
  end
end
