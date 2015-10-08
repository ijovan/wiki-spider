class PusherSocket

  def initialize(channel)
    @channel = channel
  end

  def send(message)
    puts message

    Pusher.trigger(@channel, 'my_event', {
      message: message
    })
  end

end
