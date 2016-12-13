require 'nokogiri'
require 'active_support/all'
require 'httparty'
require 'ruby-progressbar'
require 'csv'
require 'pry'

class Zendesk
  def initialize
    @root_uri = 'https://envisionapp.zendesk.com/api/v2/'
    @start_time = Time.new('2016-01-01').to_i
    @tickets_uri = @root_uri + "incremental/tickets.json?start_time=#{@start_time}"
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
      :basic_auth => {
        :username => 'adrian.smith@ennova.com.au',
        :password => 'Envision_Help13'
      }
    }
  end
end

# Represents a single ticket, including its data and metrics
class Ticket
  def initialize(info, metrics)
      @info = info
      @metrics = metrics
  end

  def info
    @info
  end

  def metrics
    @metrics
  end
end

# Represents an aggregate of metrics from multiple tickets 
class Metrics
  def initialize(tickets)
    @tickets = tickets
    @tickets_by_age = Hash.new {|age, id|}
    @tickets_by_reply = Hash.new {|priority, avg_reply_time|}
    tickets.each do |ticket|
  end

  def tickets_by_age
    
  end

  def tickets_by_reply

  end
end

# Contains methods for generating a suite of graphs based on ticket metrics
class Graphs
  def initialize

  end
end

# begin script
system 'clear'
puts 'Envision Zendesk Tickets'
puts '------------------------'

puts '-> Retrieving Tickets'
zendesk = Zendesk.new
tickets_in = zendesk.tickets
puts '   Total tickets = ' + tickets_in.count.to_s
puts

puts '-> Generating tickets summary file: all_tickets.csv'
progressbar = ProgressBar.create(title: "#{tickets.count} Tickets", starting_at: 1, format: '%a |%b>>%i| %p%% %t', total: tickets_in.count)

CSV.open("all_tickets.csv", "wb") do |csv|
  csv << zendesk.export_columns + zendesk.metric_columns
CSV.open("tickets_by_age.csv", "wb") do |csv|
  csv << zendesk.metric_columns
CSV.open("tickets_by_reply_time.csv", "wb") do |csv|
  csv << zendesk.metric_columns
end

# Import tickets from Zendesk into instances of Ticket class

tickets_in.each do |ticket|

    info = []
    metrics_info = []
    zendesk.export_colums.each do |column|
      case column
      when 'type'
        info << ticket['custom_fields'][0]['value']
      when 'user_priority'
        info << ticket['custom_fields'][1]['value']
      when 'development_priority'
        value = ticket['custom_fields'][2]['value']
        if value
          info << "d#{value[-1]}" if value[-1].to_i > 0
        else
          info << value
        end
      when 'company'
        info << ticket['custom_fields'][3]['value']
      when 'project'
        info << ticket['custom_fields'][4]['value']
      when 'platform'
        info << ticket['custom_fields'][5]['value']
      when 'function'
        info << ticket['custom_fields'][6]['value']
      when 'satisfaction_rating'
        info << ticket['satisfaction_rating']['score']
      else
        info << ticket[column]
      end
    end

    begin
      metrics = HTTParty.get("https://envisionapp.zendesk.com/api/v2/tickets/#{ticket['id']}/metrics.json", zendesk.basic_auth)
      zendesk.metric_columns.each do |column|
        if metrics['ticket_metric']
          case column
          when 'solved_at'
            metrics_info << metrics['ticket_metric'][column]
          else
            metrics_info << metrics['ticket_metric'][column]['business']
          end
        end
      end
    rescue
      retry
    end
    this = Ticket.new(info, metrics_info)
end

# Write ticket information to a csv file
tickets.each do |ticket|
  CSV.open("all_tickets.csv", "a") do |csv|
    row = []
    csv << row
    progressbar.increment
  end
end

# Agreggate ticket metrics

# Generate graphs from aggregates
