class Reader

  MAX_ITER = 50

  def initialize(target, channel)
    @target = NameHandler.clean_node_name(target)
    @socket = PusherSocket.new(channel, target, MAX_ITER)
    @css_unpacker = CSSUnpacker.new(target, "p a, div#bodyContent li a")

    scan_target
  end

  def find(start_node)
    @socket.send_connecting(start_node)

    time = Timer.measure_time do
      search(start_node)
    end

    if @result
      @socket.send_found_it(@result, @iter, time)
    else
      @socket.send_failed(@iter)
    end

    @result
  end

  private

  def scan_target
    links = CSSUnpacker.new(nil, "p a, div#content li a").acquire_links([@target, { :path => [] }])

    target_words = links.map { |link| link[0] }

    @score_handler = ScoreHandler.new(@target, target_words.uniq)
  end

  def search(link)
    @iter = 1

    @result = [link] if link.eql?(@target)

    start_node = [link, { :path => [link], :score => 0 }]

    handle_links(@css_unpacker.acquire_links(start_node))

    while (!@result && @iter <= MAX_ITER) do
      max = @score_handler.take_current_best

      @socket.send_iteration(@iter, max[1])

      handle_links(@css_unpacker.acquire_links(max))

      @iter += 1
    end
  end

  def handle_links(links)
    if links[:final_path]
      @result = links[:final_path]
    else
      @score_handler.new_scores(links)
    end
  end

end
