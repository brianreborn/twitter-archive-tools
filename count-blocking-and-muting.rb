#!/usr/bin/ruby
require_relative "twitter_archive"

dir, account = ARGV
archive = TwitterArchive.new(dir, account)

STEPS = %w(block mute)
archive.each {|zip_file, archive_date, is_last|
  counts = STEPS.collect {|step|
    json = zip_file.read("data/#{step}.js").split(' = ', 2)[1]
    JSON.parse(json).count()
  }
  puts("#{archive_date}: " +
       (0...STEPS.size()).collect {|n| "#{counts[n]} #{STEPS[n]}s"}.join(", "))
}
