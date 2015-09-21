require 'nokogiri'
require 'open-uri'

class Reader
  def self.find(start_node, end_node)
    start_node.encode("utf-8")
    end_node.encode("utf-8")

    puts "Connecting #{start_node} and #{end_node}."

    Pusher.trigger('test_channel', 'my_event', {
      message: "Connecting #{start_node} and #{end_node}."
    })

    start = Time.now

    reader = Reader.new end_node

    retval = reader.get_connection start_node

    time = Time.now - start

    retval[:iter_count] = @iter
    retval[:time] = time

    if retval[:failed]
      puts "Search failed to complete in 50 iterations."

      Pusher.trigger('test_channel', 'my_event', {
        message: "Search failed to complete in 50 iterations."
      })
    end

    path = retval[:final_path]

    puts "FOUND IT: #{path} in #{@iter} iterations and #{time.round(2)} seconds with #{path.count - 2} connecting nodes."

    Pusher.trigger('test_channel', 'my_event', {
      message: "FOUND IT: #{path} in #{@iter} iterations and #{time.round(2)} seconds with #{path.count - 2} connecting nodes."
    })
  end

  def self.find_by_url(start_url, end_url)
    start_node = start_url[/\/wiki\/.*/].sub("/wiki/", "")
    end_node = end_url[/\/wiki\/.*/].sub("/wiki/", "")

    find(start_node, end_node)
  end

  def initialize target
    if target.include? "#"
      target.sub!(target[/#.*/], "")
    end

    @target = target
    @to_visit = {}
    @visited = []
    @target_words = []
    @iter = 1

    scan_target
  end

  def scan_target
    file = Nokogiri::HTML open "https://en.wikipedia.org/wiki/#{@target}"

    links = CSSUnpacker.unpack_css file, "p a", true, [], @target
    links = links.merge(CSSUnpacker.unpack_css(file, "div#content li a", true, [], @target))

    links.each{ |link| @target_words.push(link[0]) }

    @target_words.uniq!
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

#        new_hash = unpack_css file, "div#content li a", false

#        pack_hash new_hash
#      rescue
#        puts "ERROR: #{link}"
      end

      @visited.push link

      link = @to_visit.max_by{|k,v| v[:score]}[0]

      path = @to_visit[link][:path]

      Pusher.trigger('test_channel', 'my_event', {
          message: "#{@iter} #{path} #{@to_visit[link][:score]}"
      })

      puts "#{@iter} #{path} #{@to_visit[link][:score]}"

      @iter += 1

      @to_visit.delete link
    end
  end

  def rate_score links
    links.each do |key, value|
      value[:score] = link_val(key)
      links[key] = value
    end
  end

  def link_val link
    score = 0

    parts = @target.split "_"

    parts.each do |part|
      if link.eql? part
        score += 10
      end
    end

    @target_words.each do |word|
      if link.eql? word
        score += 5
      else
        parts = word.split "_"

        parts.each do |part|
          if link.eql? part
            score += 1
          end
        end
      end
    end

    score
  end
end
