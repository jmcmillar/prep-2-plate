class Admin::Analytics::UserPreferencesFacade < BaseFacade
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
    :admin_user_preference_analytics
  end

  def nav_resource
  end

  def authorized?
    Base::AdminPolicy.new(@user, nil).index?
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("User Preference Analytics"),
    ]
  end

  # Chart data methods

  def top_brands_by_usage
    UserIngredientPreference.where.not(preferred_brand: nil)
                            .group(:preferred_brand)
                            .sum(:usage_count)
                            .sort_by { |_brand, count| -count }
                            .first(20)
                            .to_h
  end

  def preferences_learned_over_time
    UserIngredientPreference.group_by_day(:created_at, last: 30).count
  end

  def brand_preferences_by_category
    UserIngredientPreference.joins(ingredient: :ingredient_category)
                            .where.not(preferred_brand: nil)
                            .group("ingredient_categories.name", :preferred_brand)
                            .sum(:usage_count)
                            .group_by { |(category, _brand), _count| category }
                            .transform_values do |brand_counts|
                              brand_counts.map { |((_category, brand), count)| [brand, count] }
                                          .sort_by { |_brand, count| -count }
                                          .first(5)
                                          .to_h
                            end
  end

  def packaging_preferences_distribution
    UserIngredientPreference.where.not(packaging_form: nil)
                            .group(:packaging_form)
                            .sum(:usage_count)
                            .transform_keys { |key| key.titleize }
  end

  def preparation_preferences_distribution
    UserIngredientPreference.where.not(preparation_style: nil)
                            .group(:preparation_style)
                            .sum(:usage_count)
                            .transform_keys { |key| key.titleize }
  end

  def preference_usage_distribution
    usage_counts = UserIngredientPreference.pluck(:usage_count)

    {
      "Used 1 time" => usage_counts.count { |count| count == 1 },
      "Used 2-5 times" => usage_counts.count { |count| count.between?(2, 5) },
      "Used 6-10 times" => usage_counts.count { |count| count.between?(6, 10) },
      "Used 11-20 times" => usage_counts.count { |count| count.between?(11, 20) },
      "Used 20+ times" => usage_counts.count { |count| count > 20 }
    }
  end

  def preferences_by_user
    User.joins(:user_ingredient_preferences)
        .group("users.id")
        .count
        .values
        .then do |counts|
          {
            "0 preferences" => User.left_joins(:user_ingredient_preferences)
                                   .where(user_ingredient_preferences: { id: nil })
                                   .count,
            "1-5 preferences" => counts.count { |count| count.between?(1, 5) },
            "6-10 preferences" => counts.count { |count| count.between?(6, 10) },
            "11-20 preferences" => counts.count { |count| count.between?(11, 20) },
            "20+ preferences" => counts.count { |count| count > 20 }
          }
        end
  end

  def most_active_users
    User.joins(:user_ingredient_preferences)
        .group("users.email")
        .sum("user_ingredient_preferences.usage_count")
        .sort_by { |_email, count| -count }
        .first(10)
        .to_h
  end

  def preference_retention
    last_30_days = UserIngredientPreference.where("last_used_at >= ?", 30.days.ago).count
    last_60_days = UserIngredientPreference.where("last_used_at >= ? AND last_used_at < ?", 60.days.ago, 30.days.ago).count
    last_90_days = UserIngredientPreference.where("last_used_at >= ? AND last_used_at < ?", 90.days.ago, 60.days.ago).count
    older = UserIngredientPreference.where("last_used_at < ?", 90.days.ago).count

    {
      "Used in last 30 days" => last_30_days,
      "Used 30-60 days ago" => last_60_days,
      "Used 60-90 days ago" => last_90_days,
      "Used 90+ days ago" => older
    }
  end
end
