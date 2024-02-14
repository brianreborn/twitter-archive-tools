#!/usr/bin/ruby

require 'json'
require 'zip'

ZIP_FILE_DATE_PATTERN = /twitter-([0-9]{4}-[0-9]{2}-[0-9]{2})-([0-9a-f]+)\.zip$/

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

archive_file_names = []
dir, account = ARGV
Dir.open(dir) {|d|
  d.each {|file_name|
    if file_name =~ ZIP_FILE_DATE_PATTERN and $2 == account
      archive_file_names.push(file_name)
    end
  }
}
archive_file_names.sort!()
last_archive = archive_file_names[-1]

was_follower_on = {} # String: accountId => ['yyyy-mm-dd', ...]
still_follower = [] # String: accountId
still_following = [] # String: accountId
archive_file_names.each {|zip_file_name|
  Zip::File.open("#{dir}/#{zip_file_name}") {|zip_file|
    zip_file_name =~ ZIP_FILE_DATE_PATTERN
    archive_date = $1
    read_followers(zip_file).each {|follower|
      follower_account_id = follower['accountId']
      (was_follower_on[follower_account_id] ||= []).push(archive_date)
      if zip_file_name == last_archive
        still_follower.push(follower_account_id)
      end
    }
    if zip_file_name == last_archive
      read_following(zip_file).each {|following|
        following_account_id = following['accountId']
        still_following.push(following_account_id)
      }
    end
  }
}

ever_follower = was_follower_on.collect {|accountId, dates| accountId}
no_longer_follower = ever_follower - still_follower
# Check for ones we still follow, did follow us, and do not now.
unfollows = no_longer_follower & still_following
unfollows.each {|unfollower_account_id|
  puts("#{unfollower_account_id}: #{was_follower_on[unfollower_account_id].inspect()}")
}
