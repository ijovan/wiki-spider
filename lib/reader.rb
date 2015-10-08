require 'open-uri'

class Reader

  MAX_ITER = 50

  def initialize(target, channel)
    @target = NameHandler.clean_node_name(target)
    @socket = PusherSocket.new(channel, target, MAX_ITER)
    @iter = 1

    scan_target
  end

  def scan_target
    links = CSSUnpacker.new(@target, "p a, div#content li a", true).acquire_links(@target, [])

    target_words = links.map { |link| link[0] }

    @heuristic = Heuristic.new(@target, target_words.uniq)
  end

  def find(start_node)
    @socket.send_connecting(start_node)

    time = Timer.measure_time do
      get_connection(start_node)
    end

    if @result
      @socket.send_found_it(@result, @iter, time)
    else
      @socket.send_failed(@iter)
    end
  end

  def get_connection(link)
    path = [link]

    @result = path if link.eql?(@target)

    @css_unpacker = CSSUnpacker.new(@target, "p a", false)

    while !@result
      return nil if @iter > MAX_ITER

      handle_links(@css_unpacker.acquire_links(link, path))

      return if @result

      max = @heuristic.current_best

      link  = max[0]
      path  = max[1][:path]
      score = max[1][:score]

      @socket.send_iteration(@iter, path, score)

      @heuristic.mark_visited(link)

      @iter += 1
    end
  end

  def handle_links(links)
    if links[:final_path]
      @result = links[:final_path]
    else
      @heuristic.new_scores(links)
    end
  end

end
