require 'nokogiri'
require 'open-uri'
require 'byebug'

class Reader
  def self.find(start_node, end_node)
    puts "Connecting #{start_node} and #{end_node}"
    reader = Reader.new end_node
    reader.get_connection start_node
  end

  def self.find_by_url(start_url, end_url)
    start_node = start_url[/\/wiki\/.*/].sub("/wiki/", "")
    end_node = end_url[/\/wiki\/.*/].sub("/wiki/", "")
    find(start_node, end_node)
  end

  def initialize target
    t = target.encode("utf-8")

    if t.include? "#"
      t = t.sub(t[/#.*/], "")
    end

    @target = t
    @to_visit = {}
    @visited = []
    @target_words = []
    @iter = 1

    scan_target
  end

  def scan_target
    file = Nokogiri::HTML open "https://en.wikipedia.org/wiki/#{@target}"

    links = unpack_css file, "p a", true, []
    links = links.merge(unpack_css(file, "div#content li a", true, []))

    links.each do |link|
      @target_words.push link[0]
    end

    @target_words.uniq!

    @target_words
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
    @time = Time.now

    link = link.encode("utf-8")

    path = [link]

    if link.eql? @target
      return path
    end

    while true
      begin
        file = Nokogiri::HTML open "https://en.wikipedia.org/wiki/#{link}"

        new_hash = unpack_css file, "p a", false, path

        if new_hash[:final_path]
          return new_hash
        end

        pack_hash new_hash

#        new_hash = unpack_css file, "div#content li a", false

#        pack_hash new_hash
      rescue
        puts "ERROR: #{link}"
      end

      @visited.push link

      link = @to_visit.max_by{|k,v| v[:score]}[0]

      path = @to_visit[link][:path]

      puts "#{@iter} #{path} #{@to_visit[link][:score]}"

      @iter += 1

      @to_visit.delete link
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

  def unpack_css file, selector, tar, parent
    links = {}

    coll = file.css(selector)

    coll.each do |a|
      link = a["href"]

      if link.sub("/wiki/", "").eql?(@target) && !tar
        path = parent.clone.push(@target)

        time = Time.now - @time

        puts "FOUND IT: #{path} in #{@iter} iterations and #{time.round(2)} seconds with #{path.count - 2} connecting nodes."
        return { :final_path => path, :iter_count => @iter, :time => time }
      end

      if a["rel"].eql? "nofollow"
        next
      end

      if link.include?("International_Standard_Book_Number") && selector.include?("li")
        next
      end

      if link.include?("/wiki/") && !link.include?(":")
        l = a["href"].sub("/wiki/", "")

        if l.include? "#"
          l = l.sub(l[/#.*/], "")
        end

        if tar
          score = 0
        else
          score = link_val l
        end

        newarr = parent.clone

        newarr.push l

        links[l] = { :score => score, :path => newarr }
      end
    end

    links
  end
end

#Reader.find("", "")
