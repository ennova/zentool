require 'csv'
require 'date'

# Represents an aggregate of metrics from multiple tickets 
class Metrics

  MINUTES_IN_DAY = 1440
  MINUTES_IN_HOUR = 60
  PLOT_WIDTH = 200
  CURRENT_DATE = Date.today
  attr_accessor :tickets, :unsolved_tickets_by_age_log_scale, :solved_tickets_by_age_log_scale,
    :tickets_by_user_priority, :tickets_by_development_priority

  def initialize(tickets)
    @tickets = tickets
    unsolved_age
    solved_age
    avg_priority
  end

  #Creates plot data for number of solved tickets by age
  def unsolved_age
    # Hash with key as age, and the value as the number of tickets with that age
    @unsolved_tickets_by_age = Hash.new(0)

    @unsolved_tickets_by_age_log_scale = {'0' => 0, '1' => 0, '2' => 0, '3' => 0, '4' => 0,
      '5' => 0, '6-10' => 0, '11-20' => 0, '21-50' => 0, '51-100' => 0, '101+' => 0}
    @tickets.each do |ticket|
        # Rounds the age of the ticket down to the nearest day
        # puts ticket.metrics
        unless ticket.metrics['full_resolution_time_in_minutes'] 
          if ticket.metrics['initially_assigned_at']
            start_date = Date.parse ticket.metrics['initially_assigned_at']
            age = (CURRENT_DATE - start_date).to_i
            # puts age
            #Add 1 to value with key = age, create a new key if not exists
            @unsolved_tickets_by_age[age] += 1
            if age <= 5 
              @unsolved_tickets_by_age_log_scale[age.to_s] += 1
            elsif age <= 10
              @unsolved_tickets_by_age_log_scale['6-10'] += 1
            elsif age <= 20
              @unsolved_tickets_by_age_log_scale['11-20'] += 1
            elsif age <= 50
              @unsolved_tickets_by_age_log_scale['21-50'] += 1
            elsif age <= 100
              @unsolved_tickets_by_age_log_scale['51-100'] += 1
            else
              @unsolved_tickets_by_age_log_scale['101+'] += 1
            end
          end
        end
    end


  end

  #Creates plot data for number of solved tickets by ageÏ
  def solved_age
    # Hash with key as age, and the value as the number of tickets with that age
    @solved_tickets_by_age = Hash.new(0)

    @solved_tickets_by_age_log_scale = {'0' => 0, '1' => 0, '2' => 0, '3' => 0, '4' => 0,
      '5' => 0, '6-10' => 0, '11-20' => 0, '21-50' => 0, '51-100' => 0, '101+' => 0}

    @tickets.each do |ticket|
        # Rounds the age of the ticket down to the nearest day
        if ticket.metrics['full_resolution_time_in_minutes']
          age = ticket.metrics['full_resolution_time_in_minutes'] / MINUTES_IN_DAY
          #Add 1 to value with key = age, create a new key if not exists
          @solved_tickets_by_age[age] += 1
          if age <= 5 
            @solved_tickets_by_age_log_scale[age.to_s] += 1
          elsif age <= 10
            @solved_tickets_by_age_log_scale['6-10'] += 1
          elsif age <= 20
            @solved_tickets_by_age_log_scale['11-20'] += 1
          elsif age <= 50
            @solved_tickets_by_age_log_scale['21-50'] += 1
          elsif age <= 100
            @solved_tickets_by_age_log_scale['51-100'] += 1
          else
            @solved_tickets_by_age_log_scale['101+'] += 1
          end
        end
    end
  end

  #Creates plot data for average first reply time by priority
  def avg_priority
    # Hash with key => user_priority, and the value => array of reply times from tickets with that priority
    @tickets_by_user_priority = Hash.new {|h,k| h[k] = []}

    # Hash with key => development_priority, and the value => array of reply times from tickets with that priority
    @tickets_by_development_priority = Hash.new {|h,k| h[k] = []}

    # Hash with key => user_priority, and the value => average reply time of that priority
    @avg_user_priority = Hash.new(0)

    # Hash with key => development_priority, and the value => average reply time of that priority
    @avg_development_priority = Hash.new(0)

    tickets.each do |ticket|

      user_priority = ticket.info['user_priority']
      development_priority = ticket.info['development_priority']
      reply_time = ticket.metrics['reply_time_in_minutes'] 

      if user_priority == nil
          user_priority = 'None'
      end

      if development_priority == nil
          development_priority = 'None'
      end

      if reply_time
          
        #Add reply time to array with key = user_priority, create a new key if not exists
        @tickets_by_user_priority[user_priority] << reply_time

        #Add reply time to array with key = development_priority, create a new key if not exists
        @tickets_by_development_priority[ticket.info['development_priority']] << ticket.metrics['reply_time_in_minutes']
      end
    end

    @tickets_by_user_priority.each do |key, value|
        if key == nil
            key = 'None'
        end
        avg = value.inject(:+).to_f / value.length
        @avg_user_priority[key] = avg / MINUTES_IN_HOUR
    end

    @tickets_by_development_priority.each do |key, value|
        if key == nil
            key = 'None'
        end
        avg = value.inject(:+).to_f / value.length
        @avg_development_priority[key] = avg / MINUTES_IN_HOUR
    end
    @avg_development_priority.keys.sort!
  end

   #draws command line graph based on ticket metrics
  def graph
    puts
    puts 'Age of Solved Tickets'
    puts '_____________________'
  	puts 'Days     Ticket-Count'
  	@solved_tickets_by_age_log_scale.keys.each do |age|
      printf "%-10s %5d %s \n" % [age, @solved_tickets_by_age_log_scale[age], 
        '#' * @solved_tickets_by_age_log_scale[age]]
  	end

    puts
    puts 'Age of Unsolved Tickets'
    puts '_______________________'
    puts 'Days     Ticket-Count'
    @unsolved_tickets_by_age_log_scale.keys.each do |age|
      printf "%-10s %5d %s \n" % [age, @unsolved_tickets_by_age_log_scale[age], 
        '#' * @unsolved_tickets_by_age_log_scale[age]]
    end

    puts
    puts 'Average First Reply Time by Ticket Priority'
    puts '___________________________________________'
  	puts 'Priority   Reply-Time-Hours'
  	@avg_development_priority.keys.each do |development_priority|
      printf "%-10s %5d %s \n" % [development_priority, @avg_development_priority[development_priority], 
        '#' * (@avg_development_priority[development_priority] / PLOT_WIDTH)]
  	end
  end

  def save
    CSV.open("solved_tickets_by_age.csv", "wb") do |csv|
      csv << ['Days', 'Ticket-Count']
    end
    @solved_tickets_by_age_log_scale.keys.each do |age|
      CSV.open("solved_tickets_by_age.csv", "a") do |csv|
        csv << [age, @solved_tickets_by_age_log_scale[age]]
      end
    end

    CSV.open("unsolved_tickets_by_age.csv", "wb") do |csv|
      csv << ['Days', 'Ticket-Count']
    end
    @unsolved_tickets_by_age_log_scale.keys.each do |age|
      CSV.open("unsolved_tickets_by_age.csv", "a") do |csv|
        csv << [age, @unsolved_tickets_by_age_log_scale[age]]
      end
    end

    CSV.open("avg_reply_time_priority.csv", "wb") do |csv|
      csv << ['Priority', 'Average-Reply-Time']
    end
    @avg_development_priority.keys.each do |age|
      CSV.open("avg_reply_time_priority.csv", "a") do |csv|
        csv << [age, @avg_development_priority[age]]
      end
    end
  end
end