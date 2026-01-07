class Admin::UserAnalytics::IndexFacade < Base::Admin::IndexFacade
  def analytics_user
    @analytics_user ||= User.find_by(id: params[:user_id])
  end

  def base_collection
    # Not displaying a table, so return empty collection
    User.none
  end

  def resource_facade_class
    # Not displaying table rows, so return nil
    nil
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new(user_name, [:admin, analytics_user]),
      BreadcrumbComponent::Data.new("Analytics"),
    ]
  end

  def menu
    :admin_user_menu
  end

  def nav_resource
    analytics_user
  end

  def active_key
    :admin_user_analytics
  end

  def header_actions
    []
  end

  # === USER INFO ===

  def user_name
    "#{analytics_user.first_name} #{analytics_user.last_name}"
  end

  def user_email
    analytics_user.email
  end

  # === SHOPPING LIST TIME SERIES ===

  def shopping_lists_over_time
    analytics_user.shopping_lists
      .group_by_day(:created_at, last: 90)
      .count
  end

  def items_added_over_time
    analytics_user.shopping_list_items
      .unscoped # Remove default scope that filters archived
      .group_by_day(:created_at, last: 90)
      .count
  end

  def archived_items_over_time
    analytics_user.shopping_list_items
      .unscoped
      .where.not(archived_at: nil)
      .group_by_day(:archived_at, last: 90)
      .count
  end

  def average_list_size_over_time
    # This is trickier - need to calculate daily average
    lists_by_day = analytics_user.shopping_lists
      .where("created_at >= ?", 90.days.ago)
      .group("DATE(created_at)")
      .select("DATE(created_at) as date, AVG(shopping_list_items_count) as avg_size")
      .order("date")

    lists_by_day.each_with_object({}) do |record, hash|
      hash[record.date] = record.avg_size.to_f.round(1)
    end
  end

  # === SHOPPING PATTERNS ===

  def shopping_activity_by_day_of_week
    analytics_user.shopping_lists
      .group_by_day_of_week(:created_at, format: "%A")
      .count
  end

  def items_per_list_distribution
    distribution = analytics_user.shopping_lists.pluck(:shopping_list_items_count)

    {
      "1-5 items" => distribution.count { |c| c >= 1 && c <= 5 },
      "6-10 items" => distribution.count { |c| c >= 6 && c <= 10 },
      "11-20 items" => distribution.count { |c| c >= 11 && c <= 20 },
      "21-50 items" => distribution.count { |c| c >= 21 && c <= 50 },
      "50+ items" => distribution.count { |c| c > 50 }
    }
  end

  def completion_rate
    total = analytics_user.shopping_list_items.unscoped.count
    archived = analytics_user.shopping_list_items.unscoped.where.not(archived_at: nil).count
    active = total - archived

    {
      "Active Items" => active,
      "Completed Items" => archived
    }
  end

  # === INGREDIENT INSIGHTS ===

  def top_ingredients
    analytics_user.shopping_list_items
      .unscoped
      .joins(:ingredient)
      .group("ingredients.name")
      .order("count_all DESC")
      .limit(20)
      .count
  end

  def ingredient_category_distribution
    analytics_user.shopping_list_items
      .unscoped
      .joins(ingredient: :ingredient_category)
      .group("ingredient_categories.name")
      .count
  end

  def packaging_form_breakdown
    analytics_user.shopping_list_items
      .unscoped
      .where.not(packaging_form: nil)
      .group(:packaging_form)
      .count
  end

  def preparation_style_breakdown
    analytics_user.shopping_list_items
      .unscoped
      .where.not(preparation_style: nil)
      .group(:preparation_style)
      .count
  end

  # === SUMMARY STATS ===

  def total_shopping_lists
    analytics_user.shopping_lists.count
  end

  def total_items_added
    analytics_user.shopping_list_items.unscoped.count
  end

  def total_items_completed
    analytics_user.shopping_list_items.unscoped.where.not(archived_at: nil).count
  end

  def average_list_size
    avg = analytics_user.shopping_lists.average(:shopping_list_items_count)
    avg ? avg.to_f.round(1) : 0.0
  end

  def current_active_lists
    analytics_user.shopping_lists.where(current: true).count
  end

  def completion_percentage
    total = total_items_added
    return 0 if total.zero?
    ((total_items_completed.to_f / total) * 100).round(1)
  end
end
