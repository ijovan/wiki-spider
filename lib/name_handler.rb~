class NameHandler

  def self.clean_node_name(target)
    if target.include? "#"
      target.sub!(target[/#.*/], "")
    end

    target
  end

  def self.clean_url(url)
    url[/\/wiki\/.*/].sub("/wiki/", "")
  end

end
