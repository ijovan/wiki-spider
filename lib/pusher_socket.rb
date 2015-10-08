class PusherSocket

  def initialize(channel, target, max_iter)
    @channel = channel
    @target = target
    @max_iter = max_iter
  end

  def send(message)
    puts message

    Pusher.trigger(@channel, 'my_event', {
      message: message
    })
  end

  def send_connecting(start_node)
    send("Connecting #{start_node} and #{@target}.")
  end

  def send_failed
    send("Search failed to complete in #{max_iter} iterations.")
  end

  def send_found_it(path, iter, time)
    send("FOUND IT: #{path} in #{iter} iterations and #{time.round(2)} seconds with #{path.count - 2} connecting nodes.")
  end

  def send_iteration(iter, path, score)
    send("#{iter} #{path} #{score}")
  end

end
