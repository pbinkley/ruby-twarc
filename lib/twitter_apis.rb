require "tweetstream"
require_relative "./access_token"

class TwitterAPI

  def initialize(credentials)
    @credentials = credentials
  end

  def search(search_arguments)
    parse search_arguments
    twitter_response(twitter_url)
  end

  private

  def access_token
    @access_token ||= AccessToken.new(@credentials)
  end

  def parse(search_arguments)
    @query = search_arguments[:query]
    @count = search_arguments[:count].to_i
    @max_id = search_arguments[:max_id] || ""
    @since_id = search_arguments[:since_id] || ""
    @ids = search_arguments[:ids]
  end

end

class SearchAPI < TwitterAPI

  private

  def endpoint
    "https://api.twitter.com/1.1/search/tweets.json"
  end

  def twitter_url
    "#{endpoint}?q=#{@query}&count=#{@count}&max_id=#{@max_id}&since_id=#{@since_id}"
  end

  def twitter_response(url)
    results = []
    begin
      results = JSON.parse(access_token.request(:get, url).body)["statuses"]
    rescue Exception => e
      puts "ruby-twarc: #{e}"
    end
    if results.size > 0
      return results, results.last["id"]
    else
      return results, 0
    end
  end

end

class StreamAPI < TwitterAPI

  def search(search_arguments)
    parse search_arguments
    configure_tweetstream
    track
  end

  private

  def track
    results = []
    TweetStream::Client.new.track(@query) do |status|
      if @count > 0
        while results.size < @count
          puts status.to_h
          results << status.to_h
        end
        break
      else
        while true
          puts status.to_h
          trap("INT"){ exit }
        end
      end
    end
    if results.size > 0
      return results, results.last["id"]
    else
      return results, 0
    end
  end

  def configure_tweetstream
    TweetStream.configure do |config|
      config.consumer_key, config.consumer_secret, config.oauth_token, config.oauth_token_secret = @credentials.keys
      config.auth_method = :oauth
    end
  end

end

class HydrateAPI < TwitterAPI

  private

  def endpoint
    "https://api.twitter.com/1.1/statuses/lookup.json"
  end

  def twitter_url
    "#{endpoint}?id=#{@ids.join(",")}"
  end

  def twitter_response(url)
    results = []
    begin
      results = JSON.parse(access_token.request(:get, url).body)
    rescue Exception => e
      puts "ruby-twarc: #{e}"
    end
    if results.size > 0
      return results, results.last["id"]
    else
      return results, 0
    end
  end
end
