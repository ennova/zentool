require 'nokogiri'
require 'active_support/all'
require 'httparty'
require 'ruby-progressbar'
require 'pry'
require 'io/console'
require 'uri'
require 'ruby-graphviz'
require 'optparse'

require 'zentool/version'
require_relative 'zentool/zendesk_article.rb'
require_relative 'zentool/graph.rb'

options = {}

OptionParser.new do |parser|
  parser.banner = 'Usage: zentool [options]'

  parser.on('-h', '--help', 'Show this help message') do ||
    puts parser
  end

  parser.on('-u', '--username USERNAME', 'The username for the Zendesk.') do |v|
    options[:username] = v
  end

  parser.on('-p', '--password PASSWORD', 'The password for the Zendesk.') do |v|
    options[:password] = v
  end

  parser.on('-l', '--link LINK', 'The Zendesk URL.') do |v|
    options[:url] = v
  end
end.parse!

if options[:url] == NilClass || !options.key?(:url)
  print 'Zendesk URL: '
  options[:url] = gets.chomp
  puts
end
if options[:username] == NilClass || !options.key?(:username)
  print 'Zendesk username: '
  options[:username] = gets.chomp
  puts
end
if options[:password] == NilClass || !options.key?(:password)
  print 'Zendesk password: '
  options[:password] = STDIN.noecho(&:gets).chomp
  puts
end

puts

$zendesk_url = options[:url]
$zendesk_username = options[:username]
$zendesk_password = options[:password]

# Keep everything as-is before this line

i = ArticleHelper.new
i.run
