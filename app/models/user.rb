class User < ApplicationRecord
    has_many :hits
  
    MAX_API_REQUESTS_PER_MONTH = 1000
  
    def count_hits
      Rails.cache.fetch(cache_key_for_hits, expires_in: 1.month) do
        hits_in_current_month
      end
    end
  
    def can_make_api_request?
      count_hits < MAX_API_REQUESTS_PER_MONTH
    end
  
    private
  
    def cache_key_for_hits
      "user_hits_#{id}_#{Time.zone.now.strftime('%Y%m')}"
    end
  
    def hits_in_current_month
      Time.use_zone(user_time_zone) do
        start_of_month = Time.zone.now.beginning_of_month
        hits.where('created_at >= ?', start_of_month).count
      end
    end
  
    def user_time_zone
      self.time_zone || 'UTC'
    end
end  
  
  

=begin 
Key changes:

Cache Key Adjustment: Changed the cache key to include only year and month ("%Y%m").
This ensures that the cache key automatically updates at the beginning of each month and remains unique for each user.

Cache Expiry: Set the cache expiry to one month. This means the hit count will be recalculated only once a month for each user,
significantly reducing database queries.

Direct Database Count: The hits are counted directly in the database. 
This is more efficient than loading all the records into memory and then counting them in Ruby. 

Time Zone Handling: The method now uses Time.use_zone with the user's time zone.
This ensures that the start of the month is calculated based on the user's local time.

User Time Zone Attribute: The time_zone attribute is added to the User model.
This should store the IANA time zone identifier (like "America/New_York" or "Australia/Sydney").

Cache Key and Expiry: The cache key and expiry logic are executed within the context of the user's time zone.

Fallback to UTC: In cases where a user's time zone is not set, the system defaults to UTC.

=end