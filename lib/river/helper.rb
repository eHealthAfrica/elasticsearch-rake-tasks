module Ehealth
  module Helper
    # extracts the version number as integer,
    # if no index with version number is passed it returns the 0 integer
    def version(index_name)
      (index_name.match(/^\D*(\d*)/)[1] || "0").to_i
    end

    def previous_index(index)
      "#{db(index)}#{version(index) - 1}"
    end

    private

    # extracts the db reference,
    def db(index_name)
      index_name.match(/^(\D*)\d*/)[1] || "unknown"
    end

    def last(indices, selector, sorter)
      indices = indices.select(&selector).sort(&sorter)
      if indices.length > 0
        indices.last
      else
      raise Exception.new("no last element")
      end
    end

  end
end
