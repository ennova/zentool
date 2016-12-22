# Represents a single ticket, including its data and metrics

class Ticket
  attr_accessor :metrics, :info

  def initialize(info, metrics)
    @info = info
    @metrics = metrics
  end
end
