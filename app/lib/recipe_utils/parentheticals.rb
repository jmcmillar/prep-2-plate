# Separates top-level parenthetical groups from the rest of a line, handling
# nesting ("(, sliced (white or yellow))") and doubled wrappers ("((optional))").
class RecipeUtils::Parentheticals
  EDGE_PUNCTUATION = /\A[\s,;:]+|[\s,;:]+\z/

  def initialize(text)
    @text = text.to_s
  end

  # The line with every top-level group removed.
  def text
    split.first.squish
  end

  # Cleaned contents of each top-level group, in order.
  def groups
    split.last.map { |group| clean(group) }.reject(&:blank?)
  end

  private

  def split
    @split ||= scan
  end

  def scan
    outside = +""
    groups = []
    depth = 0
    @text.each_char do |char|
      depth, outside = step(char, depth, outside, groups)
    end
    [ outside, groups ]
  end

  def step(char, depth, outside, groups)
    if char == "(" && depth.zero?
      groups << +""
      outside << " "
      [ 1, outside ]
    elsif depth.zero?
      [ 0, outside << char ]
    else
      depth += { "(" => 1, ")" => -1 }.fetch(char, 0)
      groups.last << char unless depth.zero?
      [ depth, outside ]
    end
  end

  def clean(group)
    group = group.strip
    group = group[1..-2].strip while wrapped?(group)
    group.gsub(EDGE_PUNCTUATION, "")
  end

  def wrapped?(group)
    group.start_with?("(") && group.end_with?(")") && RecipeUtils::Parentheticals.new(group).text.empty?
  end
end
