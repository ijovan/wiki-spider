class NameHandler

  def self.clean_node_name(target)
    target.split("#")[0]
  end

  def self.clean_url(url)
    url[/\/wiki\/.*/].sub("/wiki/", "")
  end

end
