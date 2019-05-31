module ResponseProcessor

  def patchs_to_ranges patches
    patches.split(%r{@@ -}).map do |patch|
      if raw_range = patch[/\A\d+,\d+/]&.split(',')
        Range.new(
          (start = raw_range[0].to_i),
          start + raw_range[1].to_i
        )
      end
    end.compact
  end

  def redundant_file_urls file_attributes
    file_attributes.inject([]) do |file_urls, (file_path, attributes)|
      if (ranges = attributes[:line_ranges]).length > 1 && overlap_ranges(ranges)
        file_urls << attributes[:blob_url]
      else
        file_urls
      end
    end
  end

  def overlap_ranges ranges
    overlaping = false
    ranges.each_with_index do |comparing_range, comparing_index|
      ranges.each_with_index do |compared_range, compared_index|
        overlaping = overlaping || (
          comparing_index != compared_index &&
          comparing_range.size > 1 &&
          comparing_range.overlaps?(compared_range)
        )
      end
    end
    overlaping
  end

end
