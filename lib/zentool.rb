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
require_relative 'zentool/article_helper.rb'
require_relative 'zentool/graph.rb'
require_relative 'zentool/zendesk_ticket.rb'

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

  parser.on('-d', '--domain DOMAIN', 'The domain for zendesk. e.g. https://[YOUR_DOMAIN].zendesk.com/api/v2/help_center/en-us/') do |v|
    options[:domain] = v
  end

  parser.on('-o', '--option OPTION', 'article, tickets or both.') do |v|
    options[:option] = v.downcase[0]
  end
end.parse!

if options[:domain] == NilClass || !options.key?(:domain)
  print 'Zendesk domain: '
  options[:domain] = gets.chomp
end
if options[:username] == NilClass || !options.key?(:username)
  print 'Zendesk username: '
  options[:username] = gets.chomp
end
if options[:password] == NilClass || !options.key?(:password)
  print 'Zendesk password: '
  options[:password] = STDIN.noecho(&:gets).chomp
  puts
end
if options[:option] == NilClass || !options.key?(:option)
  print 'Option (article, ticket or both): '
  options[:option] = gets.chomp.downcase[0]
end
puts

case options[:option]
when "a"
  a = ArticleHelper.new(options[:username], options[:password], options[:domain])
  a.run
when "t"
  t = ZendeskTicket.new(options[:username], options[:password], options[:domain])
  t.run
when "b"
  a = ArticleHelper.new(options[:username], options[:password], options[:domain])
  a.run
  t = ZendeskTicket.new(options[:username], options[:password], options[:domain])
  t.run
else
  puts "Not a valid option."
end
