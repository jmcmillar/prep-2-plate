class Admin::Analytics::ShoppingListsFacade < BaseFacade
  def initialize(...)
    super
    raise Pundit::NotAuthorizedError unless authorized?
  end

  def layout
    Layout.new(menu, active_key, nav_resource)
  end

  def menu
    :admin_analytics_menu
  end

  def active_key
    :admin_shopping_list_analytics
  end

  def nav_resource
  end

  def authorized?
    Base::AdminPolicy.new(@user, nil).index?
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Shopping List Analytics"),
    ]
  end

  # Chart data methods

  def shopping_lists_over_time
    ShoppingList.group_by_day(:created_at, last: 30).count
  end

  def items_added_over_time
    ShoppingListItem.unscoped.group_by_day(:created_at, last: 30).count
  end

  def archived_items_over_time
    ShoppingListItem.unscoped.where.not(archived_at: nil).group_by_day(:archived_at, last: 30).count
  end

  def items_per_list_distribution
    data = ShoppingList.joins(:shopping_list_items)
                       .group("shopping_lists.id")
                       .count
                       .values

    # Create buckets
    {
      "1-5 items" => data.count { |count| count.between?(1, 5) },
      "6-10 items" => data.count { |count| count.between?(6, 10) },
      "11-20 items" => data.count { |count| count.between?(11, 20) },
      "21-50 items" => data.count { |count| count.between?(21, 50) },
      "50+ items" => data.count { |count| count > 50 }
    }
  end

  def top_ingredients
    ShoppingListItem.unscoped
                    .joins(:ingredient)
                    .group("ingredients.name")
                    .order("count_all DESC")
                    .limit(20)
                    .count
  end

  def packaging_form_breakdown
    ShoppingListItem.unscoped
                    .where.not(packaging_form: nil)
                    .group(:packaging_form)
                    .count
                    .transform_keys { |key| key.titleize }
  end

  def preparation_style_breakdown
    ShoppingListItem.unscoped
                    .where.not(preparation_style: nil)
                    .group(:preparation_style)
                    .count
                    .transform_keys { |key| key.titleize }
  end

  def ingredient_category_distribution
    ShoppingListItem.unscoped
                    .joins(ingredient: :ingredient_category)
                    .group("ingredient_categories.name")
                    .count
  end

  def archive_rate_by_day_of_week
    data = ShoppingListItem.unscoped
                           .where.not(archived_at: nil)
                           .group_by_day_of_week(:archived_at, format: "%A")
                           .count

    # Ensure all days are present
    days_order = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    days_order.map { |day| [day, data[day] || 0] }.to_h
  end

  def active_vs_archived_items
    {
      "Active Items" => ShoppingListItem.count,
      "Archived Items" => ShoppingListItem.unscoped.where.not(archived_at: nil).count
    }
  end

  def average_items_per_list
    total_lists = ShoppingList.count
    return {} if total_lists.zero?

    total_items = ShoppingListItem.unscoped.count
    avg = (total_items.to_f / total_lists).round(1)

    { "Average Items per List" => avg }
  end
end
