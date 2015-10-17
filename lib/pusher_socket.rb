class PusherSocket

  def initialize(channel, target, max_iter)
    @channel = channel
    @target = target
    @max_iter = max_iter
  end

  def send_connecting(start_node)
    message = {
      :type => "CONNECTING",
      :start => start_node,
      :target => @target
    }

    send(message)
  end

  def send_failed(iter)
    if (iter > @max_iter)
      message = {
        :type => "FAILED_MAX_ITER",
        :max_iter => @max_iter
      }
    else
      message = {
        :type => "FAILED"
      }
    end

    send(message)
  end

  def send_found_it(path, iter, time)
    message = {
      :type => "FOUND",
      :path => path,
      :iter => iter,
      :time => time.round(2)
    }

    send(message)
  end

  def send_iteration(iter, node)
    message = {
      :type => "ITER",
      :iter => iter,
      :path => node[:path]
    }

    send(message)
  end

  private

  def send(message)
    puts(message)

    Pusher.trigger(@channel, 'message', { message: message.to_json })
  end

end
