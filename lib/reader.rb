require 'nokogiri'
require 'open-uri'

class Reader

  def find(start_node)
    start = Time.now

    @socket.send("Connecting #{start_node} and #{@target}.")

    retval = get_connection(start_node)

    time = Time.now - start

    retval[:iter_count] = @iter
    retval[:time] = time

    if retval[:failed]
      @socket.send("Search failed to complete in 50 iterations.")
    else
      path = retval[:final_path]

      @socket.send("FOUND IT: #{path} in #{@iter} iterations and #{time.round(2)} seconds with #{path.count - 2} connecting nodes.")
    end
  end

  def initialize(target, channel)
    @target = NameHandler.clean_node_name(target)
    @to_visit = {}
    @visited = []
    @iter = 1
    @channel = channel
    @socket = PusherSocket.new(channel)

    scan_target
  end

  def scan_target
    target_words = []

    file = Nokogiri::HTML open "https://en.wikipedia.org/wiki/#{@target}"

    links = CSSUnpacker.unpack_css file, "p a", true, [], @target
    links = links.merge(CSSUnpacker.unpack_css(file, "div#content li a", true, [], @target))

    links.each{ |link| target_words.push(link[0]) }

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

    if link.eql? @target
      return path
    end

    while true
      if @iter > 50
        retval = {}

        retval[:failed] = true

        return retval
      end

      begin
        file = Nokogiri::HTML open "https://en.wikipedia.org/wiki/#{link}"

        new_hash = CSSUnpacker.unpack_css file, "p a", false, path, @target

        if new_hash[:final_path]
          return new_hash
        end

        new_hash = rate_score(new_hash)

        pack_hash new_hash
    #  rescue
    #    puts "ERROR: #{link}"
      end

      @visited.push link

      link = @to_visit.max_by{|k,v| v[:score]}[0]

      path = @to_visit[link][:path]

      @socket.send("#{@iter} #{path} #{@to_visit[link][:score]}")

      @iter += 1

      @to_visit.delete link
    end
  end

  def rate_score links
    links.each do |key, value|
      value[:score] = @heuristic.link_val(key)
      links[key] = value
    end
  end
end
