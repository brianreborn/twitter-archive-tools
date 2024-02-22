#!/usr/bin/ruby
require_relative "twitter_archive"

# data/follower.json is the Followers of the archive's account
def read_followers(zip_file)
  json_followers = zip_file.read('data/follower.js').split(' = ', 2)[1]
  JSON.parse(json_followers).collect {|follower_obj| follower_obj['follower']}
end

# data/following.json is the Follows from the archive's account
def read_following(zip_file)
  json_following = zip_file.read('data/following.js').split(' = ', 2)[1]
  JSON.parse(json_following).collect {|following_obj| following_obj['following']}
end

dir, account = ARGV
archive = TwitterArchive.new(dir, account)

was_follower_on = {} # String: accountId => ['yyyy-mm-dd', ...]
still_follower = [] # String: accountId
still_following = [] # String: accountId

archive.each {|zip_file, archive_date, is_last|
  read_followers(zip_file).each {|follower|
    follower_account_id = follower['accountId']
    (was_follower_on[follower_account_id] ||= []).push(archive_date)
    if is_last
      still_follower.push(follower_account_id)
    end
  }
  if is_last
    read_following(zip_file).each {|following|
      following_account_id = following['accountId']
      still_following.push(following_account_id)
    }
  end
}

ever_follower = was_follower_on.collect {|accountId, dates| accountId}
no_longer_follower = ever_follower - still_follower
# Check for ones we still follow, did follow us, and do not now.
unfollows = no_longer_follower & still_following
unfollows.each {|unfollower_account_id|
  puts("#{unfollower_account_id}: #{was_follower_on[unfollower_account_id].inspect()}")
}
