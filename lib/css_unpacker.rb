class CSSUnpacker
  def self.unpack_css file, selector, tar, parent, target
    @target = target
    links = {}

    coll = file.css(selector)

    coll.each do |a|
      link = a["href"]

      if link.sub("/wiki/", "").eql?(@target) && !tar
        path = parent.clone.push(@target)

        return { :final_path => path }
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

        newarr = parent.clone

        newarr.push l

        links[l] = { :path => newarr }
      end
    end

    links
  end
end
