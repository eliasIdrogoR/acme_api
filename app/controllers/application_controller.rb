class ApplicationController < ActionController::API
    before_action :user_quota
  
    def user_quota
      render json: { error: 'over quota' }, status: 429 if current_user.count_hits >= 10000
    end

    def check_api_limit
        unless current_user.can_make_api_request?
          render json: { error: 'API request limit reached' }, status: :forbidden
          return
        end
        current_user.hits.create!
    end
end


=begin
Root Cause
When the count_hits method calculates the beginning of the month, it uses the server's time zone.
If the server is not in the same time zone as the user, this can lead to discrepancies. For instance,
when it's still October 31st in the server's time zone, it might already be November 1st in the user's local time zone
(like in Australia), leading to unexpected "over quota" errors.
=end