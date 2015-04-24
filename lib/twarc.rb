require "json"
require "oauth"

class Twarc

  attr_reader :consumer_key, :consumer_secret, :access_token, :access_token_secret

  def initialize(arguments = {})
    @consumer_key = arguments[:consumer_key]
    @consumer_secret = arguments[:consumer_secret]
    @access_token = arguments[:access_token]
    @access_token_secret = arguments[:access_token_secret]

  end

  def search(arguments = {})

    query = arguments[:query]
    max_id = arguments[:max_id] || ""
    since_id = arguments[:since_id] || ""

    endpoint = "https://api.twitter.com/1.1/search/tweets.json"
    url = "#{endpoint}?q=#{query}&count=100&since_id=#{max_id}&since_id=#{since_id}"
    access_token = prepare_access_token(@access_token, @access_token_secret)
    response = access_token.request(:get, url)
    JSON.parse(response.body)["statuses"]
  end

  private

  def prepare_access_token(oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, {site: "https://api.twitter.com", scheme: :header})
    token_hash = {oauth_token: oauth_token, oauth_token_secret: oauth_token_secret}
    OAuth::AccessToken.from_hash(consumer, token_hash)
  end
end
