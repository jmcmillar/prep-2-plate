class RecipeUtils::UnicodeFractions
  # Map of Unicode fraction characters to their ASCII equivalents
  UNICODE_FRACTION_MAP = {
    '¼' => '1/4',
    '½' => '1/2',
    '¾' => '3/4',
    '⅐' => '1/7',
    '⅑' => '1/9',
    '⅒' => '1/10',
    '⅓' => '1/3',
    '⅔' => '2/3',
    '⅕' => '1/5',
    '⅖' => '2/5',
    '⅗' => '3/5',
    '⅘' => '4/5',
    '⅙' => '1/6',
    '⅚' => '5/6',
    '⅛' => '1/8',
    '⅜' => '3/8',
    '⅝' => '5/8',
    '⅞' => '7/8'
  }.freeze

  # Regex pattern that matches any Unicode fraction character
  UNICODE_FRACTION_PATTERN = /[#{UNICODE_FRACTION_MAP.keys.join}]/

  def self.convert(text)
    return text if text.blank?

    result = text.dup
    UNICODE_FRACTION_MAP.each do |unicode_char, ascii_fraction|
      result.gsub!(unicode_char, ascii_fraction)
    end
    result
  end

  def self.contains_unicode_fraction?(text)
    return false if text.blank?
    text.match?(UNICODE_FRACTION_PATTERN)
  end
end
