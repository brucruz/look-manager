module ApplicationHelper
  def common_prefix(array_of_strings)
    raise "Array is empty" if array_of_strings.empty?
    raise "Array elements are null" if array_of_strings.any? { |str| str.nil? }

    prefix = array_of_strings.first
    array_of_strings[1..-1].each do |str|
      i = 0
      while i < prefix.length && i < str.length && prefix[i] == str[i]
        i += 1
      end
      prefix = prefix[0...i]
    end

    prefix
  end
end
