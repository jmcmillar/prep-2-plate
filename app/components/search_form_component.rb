class SearchFormComponent < ApplicationComponent
  Data = Struct.new(
    :field,
    :form_url,
    :label,
    :query,
    keyword_init: true)
    
  def initialize(search_data, **options)
    @field = search_data.field
    @form_url = search_data.form_url
    @label = search_data.label
    @query = search_data.query
    @advance = options.fetch(:advance, true)
  end
end
