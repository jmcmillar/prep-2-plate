require "test_helper"

class Resources::IndexFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Resources::IndexFacade.new(@user, {})
  end

  def test_base_collection
    collection = @facade.base_collection
    
    assert_kind_of ActiveRecord::Relation, collection
  end

  def test_collection
    assert_kind_of CollectionBuilder, @facade.collection
  end

  def test_search_data
    search_data = @facade.search_data
    
    assert_kind_of SearchFormComponent::Data, search_data
    assert_equal [:resources], search_data.form_url
    assert_equal "Search Name", search_data.label
  end

  def test_search_fields
    assert_equal :name_cont, @facade.search_fields
  end

  def test_search_label
    assert_equal "Search Resources", @facade.search_label
  end

  def test_resource_facade_class
    assert_equal Resources::ResourceFacade, @facade.resource_facade_class
  end
end
