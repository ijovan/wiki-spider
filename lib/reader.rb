require 'nokogiri'
require 'open-uri'

class Reader

  MAX_ITER = 50

  def find(start_node)
    @socket.send_connecting(start_node)

    start = Time.now

    retval = get_connection(start_node)

    time = Time.now - start

    retval[:iter_count] = @iter
    retval[:time] = time

    if retval
      @socket.send_found_it(retval[:final_path], @iter, time)
    else
      @socket.send_failed
    end
  end

  def initialize(target, channel)
    @target = NameHandler.clean_node_name(target)
    @to_visit = {}
    @visited = []
    @iter = 1
    @socket = PusherSocket.new(channel, target, MAX_ITER)

    scan_target
  end

  def scan_target
    css_unpacker = CSSUnpacker.new(@target, "p a, div#content li a", true)

    file = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/#{@target}"))

    links = css_unpacker.unpack(file, [])

    target_words = links.map { |link| link[0] }

    @heuristic = Heuristic.new(@target, target_words.uniq)
  end

  def pack_hash new_hash
    new_hash.each do |key, value|
      unless @visited.include? key
        if @to_visit.has_key? key
          val = @to_visit[key]

          @to_visit[key][:score] = val[:score] + value[:score]
        else
          @to_visit[key] = value
        end
      end
    end
  end

  def get_connection link
    path = [link]

    return path if link.eql?(@target)

    css_unpacker = CSSUnpacker.new(@target, "p a", false)

    while true
      return nil if @iter > MAX_ITER

      begin
        file = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/#{link}"))

        new_hash = css_unpacker.unpack(file, path)

        return new_hash if new_hash[:final_path]

        pack_hash(@heuristic.rate_score(new_hash))
      rescue
        puts "ERROR: #{link}"
      end

      @visited.push(link)

      link = @to_visit.max_by { |k,v| v[:score] }[0]

      to_visit = @to_visit[link]

      path = to_visit[:path]

      @socket.send_iteration(@iter, path, to_visit[:score])

      @iter += 1

      @to_visit.delete(link)
    end
  end

end
