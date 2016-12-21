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

  attr_accessor :root_uri, :start_time, :tickets_uri, :domain, :username, :password

  def initialize(username, password, domain)
    @root_uri = "https://#{domain}.zendesk.com/api/v2/"
    @start_time = Time.new('2016-01-01').to_i
    @tickets_uri = @root_uri + "incremental/tickets.json?start_time=#{@start_time}"
    @username, @password, @domain = username, password, domain
  end

  def run

    puts 'Checking authentication...'
    check_auth
    puts 'Authentication successful!'
    puts
    puts 'Envision Zendesk Tickets'
    puts '------------------------'
    puts '-> Retrieving Tickets...'

    tickets_in = self.download_tickets
    tickets = self.retrieve_fields(tickets_in)
    metrics = Metrics.new(tickets)
    metrics.graph
    metrics.save
  end

  def download_tickets
    @tickets ||= begin

      first_page = HTTParty.get(@tickets_uri, basic_auth)
      # puts first_page
      tickets = first_page['tickets']
      next_url = first_page['next_page']
      count = first_page['count']
      puts "   Got: #{count}"

      while count == 1000
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
    %w(id type subject status user_priority development_priority company project
       platform function satisfaction_rating created_at updated_at)
  end

  def metric_columns
    %w(initially_assigned_at solved_at full_resolution_time_in_minutes
       requester_wait_time_in_minutes reply_time_in_minutes)
  end

  def basic_auth
    {
      basic_auth: {
        username: @username,
        password: @password
      }
    }
  end

  def check_auth
    response = HTTParty.get(@tickets_uri, basic_auth)
    unless response.code == 200
      puts "Error #{response.code}: #{response.message}"
      abort
    end
  end

  def retrieve_fields(tickets_in)

    puts '   Total tickets = ' + tickets_in.count.to_s
    puts

    CSV.open('all_tickets.csv', 'wb') do |csv|
      csv << self.export_columns + self.metric_columns
    end

    tickets = Array.new

    print "Enter number of tickets (max of #{tickets_in.count.to_s}): "
    number_of_tickets = gets.chomp.to_i
    puts

    progressbar = ProgressBar.create(title: "#{number_of_tickets} Tickets",
      starting_at: 0, format: '%a |%b>>%i| %p%% %t', total: number_of_tickets)

    tickets_in.first(number_of_tickets).each do |ticket|
      CSV.open('all_tickets.csv', 'a') do |csv|
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
            else
              info['development_priority'] = value
            end
            row << info['development_priority']
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
          metrics = HTTParty.get("#{@root_uri}tickets/#{ticket['id']}/metrics.json", self.basic_auth)
          self.metric_columns.each do |column|
            if metrics['ticket_metric']
              case column
              when 'solved_at', 'initially_assigned_at'
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
