class Heuristic

  def initialize(target, target_words)
    @target = target
    @target_words = target_words
  end

  def link_val(link)
    compare_target(link) + compare_words(link)
  end

  private

  def compare_target(link)
    score = 0

    parts = @target.split("_")

    parts.each { |part| score += 10 if link.eql?(part) }

    score
  end

  def compare_words(link)
    score = 0

    @target_words.each do |word|
      if link.eql? word
        score += 5
      else
        parts = word.split("_")

        parts.each { |part| score += 1 if link.eql?(part) }
      end
    end

    score
  end

end
