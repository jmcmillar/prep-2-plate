# frozen_string_literal: true

require "test_helper"

class TableComponentTest < ViewComponent::TestCase
  def test_component_renders
    @header_data = [
      Table::DefaultHeaderComponent.new("Song Title"),
      Table::DefaultHeaderComponent.new("Band"),
      Table::DefaultHeaderComponent.new("Genre")
    ]
    @row_data = [
      Table::RowComponent.new(
        [Table::DataComponent.new("Zombie"),
        Table::DataComponent.new("The Cranberries")]
      ),
      Table::RowComponent.new(
        [Table::DataComponent.new("Rappers Delight"),
        Table::DataComponent.new("Sugar Hill Gang")]
      )
    ]
    @component = TableComponent.new(@header_data, @row_data)
    render_inline(@component)
    assert_selector "div", class: "rounded"
    assert_selector "table", class: "table-auto w-full"
  end
end
