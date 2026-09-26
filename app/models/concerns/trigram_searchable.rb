# Autocomplete-style name matching backed by pg_trgm. Matches names that start
# with the term, contain a word starting with it, or are a close fuzzy match
# ("chiken" -> "chicken"), ranked in that order.
module TrigramSearchable
  extend ActiveSupport::Concern

  class_methods do
    def trigram_search(term)
      term = term.to_s.squish.downcase
      column = "lower(#{table_name}.name)"
      prefix = "#{sanitize_sql_like(term)}%"
      word_start = "% #{sanitize_sql_like(term)}%"

      where("#{column} LIKE :prefix OR #{column} LIKE :word_start OR :term <% #{column}", prefix:, word_start:, term:)
        .order(Arel.sql(sanitize_sql_array([
          "CASE WHEN #{column} LIKE ? THEN 0 WHEN #{column} LIKE ? THEN 1 ELSE 2 END, word_similarity(?, #{column}) DESC, #{column}",
          prefix, word_start, term
        ])))
    end
  end
end
