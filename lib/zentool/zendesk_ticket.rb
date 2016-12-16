require 'nokogiri'
require 'active_support/all'
require 'httparty'
require 'ruby-progressbar'
require 'csv'
require 'pry'
require 'optparse'
require_relative 'metrics'
require_relative 'ticket'

class ZendeskTicket
  def initialize(username, password, domain)
    @root_uri = "https://#{domain}.zendesk.com/api/v2/"
    @start_time = Time.new('2016-01-01').to_i
    @tickets_uri = @root_uri + "incremental/tickets.json?start_time=#{@start_time}"
    @username, @password = username, password
    check_auth
  end

  def run
    puts 'Envision Zendesk Tickets'
    puts '------------------------'
    puts '-> Retrieving Tickets'

    tickets_in = self.tickets
    tickets = self.retrieve_tickets(tickets_in)
    metrics = Metrics.new(tickets)
    metrics.graph
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
        username: @username,
        password: @password,
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

  def retrieve_tickets(tickets_in)

    puts '   Total tickets = ' + tickets_in.count.to_s
    puts
    puts '-> Generating tickets summary file: all_tickets.csv'

    progressbar = ProgressBar.create(title: "#{tickets_in.count} Tickets", starting_at: 1, format: '%a |%b>>%i| %p%% %t', total: tickets_in.count)

    puts 'Importing tickets from Zendesk into all_tickets.csv'

    CSV.open("all_tickets.csv", "wb") do |csv|
      csv << self.export_columns + self.metric_columns
    end

    tickets = Array.new

    print "Enter number of tickets (max of #{tickets_in.count.to_s}): "
    number_of_tickets = gets.chomp.to_i
    puts

    tickets_in.first(number_of_tickets).each do |ticket|
      CSV.open("all_tickets.csv", "a") do |csv|
        row = []
        info = Hash.new
        metrics_info = Hash.new
        self.export_columns.each do |column|
          case column
          when 'type'
            info['type'] = ticket['custom_fields'][0]['value']
            row << info['type']
          when 'user_priority'
            info['user_priority'] = ticket['custom_fields'][1]['value']
            row << info['user_priority']
          when 'development_priority'
            value = ticket['custom_fields'][2]['value']
            if value
              info['development_priority'] = "d#{value[-1]}" if value[-1].to_i > 0
              row << info['development_priority']
            else
              info['development_priority'] = value
              row << info['development_priority']
            end
          when 'company'
            info['company'] = ticket['custom_fields'][3]['value']
            row << info['company']
          when 'project'
            info['project'] = ticket['custom_fields'][4]['value']
            row << info['project']
          when 'platform'
            info['platform'] = ticket['custom_fields'][5]['value']
            row << info['platform']
          when 'function'
            info['function'] = ticket['custom_fields'][6]['value']
            row << info['function']
          when 'satisfaction_rating'
            info['satisfaction_rating'] = ticket['satisfaction_rating']['score']
            row << info['satisfaction_rating']
          else
            info[column] = ticket[column]
            row << info['type']
          end
        end

        begin
          metrics = HTTParty.get("https://envisionapp.zendesk.com/api/v2/tickets/#{ticket['id']}/metrics.json", self.basic_auth)
          self.metric_columns.each do |column|
            if metrics['ticket_metric']
              case column
              when 'solved_at'
                metrics_info[column] = metrics['ticket_metric'][column]
              else
                metrics_info[column] = metrics['ticket_metric'][column]['business']
              end
              row << metrics_info[column]
            end
          end
        rescue
          retry
        end

        this = Ticket.new(info, metrics_info)
        tickets << this
        csv << row
        progressbar.increment
      end
    end
    tickets
  end
end
