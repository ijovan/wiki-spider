class Timer

  def self.measure_time
    start = Time.now

    yield

    Time.now - start
  end

end
