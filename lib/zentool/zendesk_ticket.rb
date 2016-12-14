require 'nokogiri'
require 'active_support/all'
require 'httparty'
require 'ruby-progressbar'
require 'csv'
require 'pry'
require 'optparse'
require_relative 'metrics'
require_relative 'ticket'

class Zendesk
  def initialize
    @root_uri = 'https://envisionapp.zendesk.com/api/v2/'
    @start_time = Time.new('2016-01-01').to_i
    @tickets_uri = @root_uri + "incremental/tickets.json?start_time=#{@start_time}"
    check_auth
  end

  def tickets
    @tickets ||= begin

      first_page = HTTParty.get(@tickets_uri, basic_auth)
      tickets = first_page['tickets']
      next_url = first_page['next_page']
      count = first_page['count']
      puts "   Got: #{count}"

      while count == 1000 do
        next_page = HTTParty.get(next_url, basic_auth)
        tickets += next_page['tickets']
        next_url = next_page['next_page']
        count = next_page['count']
        puts "   Got: #{count}"
      end
    end
    tickets
  end
    
  def export_columns
    ['id', 'type', 'subject', 'status', 'user_priority', 'development_priority', 'company', 'project', 'platform', 'function', 'satisfaction_rating', 'created_at', 'updated_at']
  end

  def metric_columns
    ['solved_at', 'full_resolution_time_in_minutes', 'requester_wait_time_in_minutes', 'reply_time_in_minutes']
  end

  def basic_auth
    {
      basic_auth: {
        username: $zendesk_username,
        password: $zendesk_password,
      },
    }
  end

  def check_auth
    response = HTTParty.get(@tickets_uri, basic_auth)
    unless response.code == 200
      puts "Error #{response.code}: #{response.message}"
      abort
    end
  end
end


# begin script
system 'clear'

options = {}

OptionParser.new do |parser|
  parser.banner = "Usage: zentool [options]"

  parser.on("-h", "--help", "Show this help message") do ||
    puts parser
  end

  parser.on("-u", "--username USERNAME", "The username for the Zendesk.") do |v|
    options[:username] = v
  end

  parser.on("-p", "--password PASSWORD", "The password for the Zendesk.") do |v|
    options[:password] = v
  end

  parser.on("-l", "--link LINK", "The Zendesk URL.") do |v|
    options[:url] = v
  end
end.parse!

def wrap(s, width = 20)
  s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
end

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

puts 'Envision Zendesk Tickets'
puts '------------------------'

puts '-> Retrieving Tickets'
zendesk = Zendesk.new
tickets_in = zendesk.tickets
puts '   Total tickets = ' + tickets_in.count.to_s
puts

puts '-> Generating tickets summary file: all_tickets.csv'
progressbar = ProgressBar.create(title: "#{tickets_in.count} Tickets", starting_at: 1, format: '%a |%b>>%i| %p%% %t', total: tickets_in.count)

CSV.open("all_tickets.csv", "wb") do |csv|
  csv << zendesk.export_columns + zendesk.metric_columns
# CSV.open("tickets_by_age.csv", "wb") do |csv|
#   csv << zendesk.metric_columns
# CSV.open("tickets_by_reply_time.csv", "wb") do |csv|
#   csv << zendesk.metric_columns
end

puts 'Importing tickets from Zendesk into instances of Ticket class'

tickets = Array.new
tickets_in.first(10).each do |ticket|
    info = Hash.new
    metrics_info = Hash.new
    zendesk.export_columns.each do |column|
      case column
      when 'type'
        info['type'] = ticket['custom_fields'][0]['value']
      when 'user_priority'
        info['user_priority'] = ticket['custom_fields'][1]['value']
      when 'development_priority'
        value = ticket['custom_fields'][2]['value']
        if value
          info['development_priority'] = "d#{value[-1]}" if value[-1].to_i > 0
        else
          info['development_priority'] = value
        end
      when 'company'
        info['company'] = ticket['custom_fields'][3]['value']
      when 'project'
        info['project'] = ticket['custom_fields'][4]['value']
      when 'platform'
        info['platform'] = ticket['custom_fields'][5]['value']
      when 'function'
        info['function'] = ticket['custom_fields'][6]['value']
      when 'satisfaction_rating'
        info['satisfaction_rating'] = ticket['satisfaction_rating']['score']
      else
        info[column] = ticket[column]
      end
    end

    begin
      metrics = HTTParty.get("https://envisionapp.zendesk.com/api/v2/tickets/#{ticket['id']}/metrics.json", zendesk.basic_auth)
      zendesk.metric_columns.each do |column|
        if metrics['ticket_metric']
          case column
          when 'solved_at'
            metrics_info[column] = metrics['ticket_metric'][column]
          else
            metrics_info[column] = metrics['ticket_metric'][column]['business']
          end
        end
      end
    rescue
      retry
    end
	progressbar.increment
    this = Ticket.new(info, metrics_info)
    tickets << this

end

puts 'Writing ticket information to all_tickets.csv'
tickets.each do |ticket|
	row = []
  CSV.open("all_tickets.csv", "a") do |csv|
    row << ticket.info
    row << ticket.metrics
    csv << row

  end
end

metrics = Metrics.new(tickets)
metrics.graph

# Agreggate ticket metrics
# tickets.each do |ticket|

# Generate graphs from aggregates