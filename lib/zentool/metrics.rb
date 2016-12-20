require 'csv'
require 'date'

# Represents an aggregate of metrics from multiple tickets
class Metrics

  MINUTES_IN_DAY = 1440
  MINUTES_IN_HOUR = 60
  PLOT_WIDTH = 200
  CURRENT_DATE = Date.today
  attr_accessor :tickets, :avg_user_priority, :avg_development_priority,
    :unsolved_tickets_by_age_log_scale, :solved_tickets_by_age_log_scale

  def initialize(tickets)
    @tickets = tickets
    @log_scale = {'0' => 0, '1' => 0, '2' => 0, '3' => 0, '4' => 0,
      '5' => 0, '6-10' => 0, '11-20' => 0, '21-50' => 0, '51-100' => 0, '101+' => 0}
    unsolved_age
    solved_age
    @avg_user_priority = avg_priority('user_priority')
    @avg_development_priority = avg_priority('development_priority')
  end

  def plot_as_log(tickets_by_log_scale, age)
    if age <= 5
      tickets_by_log_scale[age.to_s] += 1
    elsif age <= 10
      tickets_by_log_scale['6-10'] += 1
    elsif age <= 20
      tickets_by_log_scale['11-20'] += 1
    elsif age <= 50
      tickets_by_log_scale['21-50'] += 1
    elsif age <= 100
      tickets_by_log_scale['51-100'] += 1
    else
      tickets_by_log_scale['101+'] += 1
    end
    tickets_by_log_scale
  end

  # Creates plot data for number of solved tickets by age
  def unsolved_age

    @unsolved_tickets_by_age_log_scale = @log_scale

    @tickets.each do |ticket|
      metrics = ticket.metrics
      # Rounds the age of the ticket down to the nearest day
      unless metrics['full_resolution_time_in_minutes']
        if metrics['initially_assigned_at']
          start_date = Date.parse metrics['initially_assigned_at']
          age = (CURRENT_DATE - start_date).to_i
          @solved_tickets_by_age_log_scale = plot_as_log(@solved_tickets_by_age_log_scale, age)
        end
      end
    end
  end

  # Creates plot data for number of solved tickets by age
  def solved_age

    @solved_tickets_by_age_log_scale = @log_scale

    @tickets.each do |ticket|
      metrics = ticket.metrics
      # Rounds the age of the ticket down to the nearest day
      if metrics['full_resolution_time_in_minutes']
        age = metrics['full_resolution_time_in_minutes'] / MINUTES_IN_DAY
        @solved_tickets_by_age_log_scale = plot_as_log(@solved_tickets_by_age_log_scale, age)
      end
    end
  end

  # Creates plot data for average first reply time by priority
  def avg_priority(priority_type)
    # Hash with key => user_priority, and the value => array of reply times from tickets with that priority
    tickets_by_priority = Hash.new {|h,k| h[k] = []}

    # Hash with key => user_priority, and the value => average reply time of that priority
    avg_priority = Hash.new(0)

    tickets.each do |ticket|

      priority = ticket.info[priority_type]
      reply_time = ticket.metrics['reply_time_in_minutes']

      if priority == nil
          priority = 'None'
      end

      if reply_time
        tickets_by_priority[priority] << reply_time
      end
    end

    tickets_by_priority.each do |key, value|
        if key == nil
            key = 'None'
        end
        avg = value.inject(:+).to_f / value.length
        avg_priority[key] = avg / MINUTES_IN_HOUR
    end
    avg_priority
  end

  # draws command line graph based on ticket metrics
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
    puts 'Average First Reply Time by Development Priority'
    puts '___________________________________________'
  	puts 'Priority   Reply-Time-Hours'
  	@avg_development_priority.keys.sort.each do |development_priority|
      printf "%-10s %5d %s \n" % [development_priority, @avg_development_priority[development_priority],
        '#' * (@avg_development_priority[development_priority] / PLOT_WIDTH)]
  	end

    puts
    puts 'Average First Reply Time by User Priority'
    puts '___________________________________________'
    puts 'Priority   Reply-Time-Hours'
    @avg_user_priority.keys.sort.each do |user_priority|
      printf "%-10s %5d %s \n" % [user_priority, @avg_user_priority[user_priority],
        '#' * (@avg_user_priority[user_priority] / PLOT_WIDTH)]
    end
  end

  def save
    CSV.open('solved_tickets_by_age.csv', 'wb') do |csv|
      csv << ['Days', 'Ticket-Count']
    end
    @solved_tickets_by_age_log_scale.keys.each do |age|
      CSV.open('solved_tickets_by_age.csv', 'a') do |csv|
        csv << [age, @solved_tickets_by_age_log_scale[age]]
      end
    end

    CSV.open('unsolved_tickets_by_age.csv', 'wb') do |csv|
      csv << ['Days', 'Ticket-Count']
    end
    @unsolved_tickets_by_age_log_scale.keys.each do |age|
      CSV.open('unsolved_tickets_by_age.csv', 'a') do |csv|
        csv << [age, @unsolved_tickets_by_age_log_scale[age]]
      end
    end

    CSV.open('avg_reply_time_priority.csv', 'wb') do |csv|
      csv << ['Priority', 'Average-Reply-Time']
    end
    @avg_development_priority.keys.sort.each do |age|
      CSV.open('avg_reply_time_priority.csv', 'a') do |csv|
        csv << [age, @avg_development_priority[age]]
      end
    end
  end
end
