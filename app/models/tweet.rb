# encoding: utf-8
class Tweet < ActiveRecord::Base
  belongs_to :politician

  has_many :tweet_images, :foreign_key => "tweet_id"

  scope :with_content, -> { where.not content: nil}
  scope :retweets, -> { where.not retweeted_id: nil}

  before_save :extract_retweet_fields

  cattr_reader :per_page
  @@per_page = 10

  def self.in_order
    includes(:politician).order('modified DESC')
  end

  def self.latest
    order('created DESC')
  end

  def self.deleted
    where(deleted: 1).where.not(content: nil)
  end

  def self.in_year(year)
    where("created >= #{Date.new(year, 1, 1)}").where("created <= #{Date.new(year, 12, 31)}")
  end

  def self.random
    Tweet.find(Tweet.pluck(:id).shuffle.first)
  end

  def details
    JSON.parse(tweet)
  end

  def extract_retweeted_status
    return nil if tweet.nil?
    orig_obj = JSON::parse(tweet) rescue nil
    return nil if orig_obj.nil?
    return nil if not orig_obj.is_a?(Hash)
    return nil if orig_obj["retweeted_status"].nil?

    return orig_obj["retweeted_status"]
  end

  def extract_retweet_fields (options = {})
    if retweeted_id.nil? || !options[:overwrite].nil?
      orig_hash = extract_retweeted_status
      if orig_hash
        self.retweeted_id = orig_hash["id"]
        self.retweeted_content = orig_hash["text"]
        self.retweeted_user_name = orig_hash["user"]["screen_name"]
      end
    end
  end

  def twitter_url
    "https://www.twitter.com/#{user_name}/status/#{id}"
  end

  def format
    {
      :created_at => created,
      :updated_at => modified,
      :id => (id and id.to_s),
      :politician_id => politician_id,
      :details => details,
      :content => content,
      :user_name => user_name
    }
  end
end
