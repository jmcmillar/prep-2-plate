class DuplicateIngredientConsolidationJob < ApplicationJob
  queue_as :default

  # Log prefix for easy filtering
  LOG_PREFIX = "INGREDIENT_CONSOLIDATION:"

  def perform
    Rails.logger.info "#{LOG_PREFIX} Starting duplicate ingredient consolidation..."

    duplicate_groups = find_duplicate_groups

    if duplicate_groups.empty?
      Rails.logger.info "#{LOG_PREFIX} No duplicate ingredients found."
      return
    end

    Rails.logger.info "#{LOG_PREFIX} Found #{duplicate_groups.size} groups of duplicates."

    consolidated_count = 0
    failed_count = 0
    total_duplicates_removed = 0

    duplicate_groups.each do |group_info|
      duplicate_set = fetch_duplicate_ingredients(
        group_info.normalized_name,
        group_info.normalized_packaging,
        group_info.normalized_prep
      )

      Rails.logger.info "#{LOG_PREFIX} Processing '#{duplicate_set.first.name}' (#{duplicate_set.size} duplicates)..."

      stats = consolidate_duplicate_group(duplicate_set)

      if stats
        consolidated_count += 1
        total_duplicates_removed += stats[:duplicate_count]
        log_consolidation_stats(stats)
      else
        failed_count += 1
      end
    end

    Rails.logger.info "#{LOG_PREFIX} Consolidation complete!"
    Rails.logger.info "#{LOG_PREFIX} Successfully consolidated: #{consolidated_count} groups"
    Rails.logger.info "#{LOG_PREFIX} Failed: #{failed_count} groups"
    Rails.logger.info "#{LOG_PREFIX} Total duplicate ingredients removed: #{total_duplicates_removed}"
  end

  private

  def find_duplicate_groups
    Ingredient
      .select("LOWER(name) as normalized_name,
               COALESCE(packaging_form, '') as normalized_packaging,
               COALESCE(preparation_style, '') as normalized_prep,
               COUNT(*) as duplicate_count")
      .group("LOWER(name), COALESCE(packaging_form, ''), COALESCE(preparation_style, '')")
      .having("COUNT(*) > 1")
  end

  def fetch_duplicate_ingredients(normalized_name, normalized_packaging, normalized_prep)
    # Convert normalized values back to actual values or nil
    packaging = normalized_packaging.blank? ? nil : normalized_packaging
    prep = normalized_prep.blank? ? nil : normalized_prep

    Ingredient
      .where("LOWER(name) = ?", normalized_name)
      .where(packaging_form: packaging)
      .where(preparation_style: prep)
      .order(created_at: :asc) # Oldest first
  end

  def select_canonical_ingredient(duplicate_set)
    # Already ordered by created_at ASC, so first is oldest
    canonical = duplicate_set.first
    duplicates = duplicate_set[1..]

    [canonical, duplicates]
  end

  def consolidate_duplicate_group(duplicate_set)
    canonical, duplicates = select_canonical_ingredient(duplicate_set)
    duplicate_ids = duplicates.map(&:id)

    ActiveRecord::Base.transaction do
      stats = {
        canonical_id: canonical.id,
        canonical_name: canonical.name,
        duplicate_count: duplicates.size,
        recipe_ingredients: 0,
        shopping_list_items: 0,
        offering_ingredients: 0,
        user_preferences_migrated: 0,
        user_preferences_merged: 0
      }

      # Migrate all foreign key relationships
      stats[:recipe_ingredients] = migrate_recipe_ingredients(duplicate_ids, canonical.id)
      stats[:shopping_list_items] = migrate_shopping_list_items(duplicate_ids, canonical.id)
      stats[:offering_ingredients] = migrate_offering_ingredients(duplicate_ids, canonical.id)
      migrated, merged = migrate_user_ingredient_preferences(duplicate_ids, canonical.id)
      stats[:user_preferences_migrated] = migrated
      stats[:user_preferences_merged] = merged

      # Delete duplicates
      delete_duplicate_ingredients(duplicate_ids)

      stats
    end
  rescue StandardError => e
    Rails.logger.error "#{LOG_PREFIX} Failed to consolidate '#{duplicate_set.first.name}': #{e.message}"
    Rails.logger.error "#{LOG_PREFIX} #{e.backtrace.first(3).join("\n")}"
    nil # Return nil to indicate failure
  end

  def migrate_recipe_ingredients(from_ingredient_ids, to_ingredient_id)
    updated_count = RecipeIngredient
      .where(ingredient_id: from_ingredient_ids)
      .update_all(ingredient_id: to_ingredient_id)

    Rails.logger.info "#{LOG_PREFIX} Migrated #{updated_count} RecipeIngredient records"
    updated_count
  end

  def migrate_shopping_list_items(from_ingredient_ids, to_ingredient_id)
    updated_count = ShoppingListItem.unscoped
      .where(ingredient_id: from_ingredient_ids)
      .update_all(ingredient_id: to_ingredient_id)

    Rails.logger.info "#{LOG_PREFIX} Migrated #{updated_count} ShoppingListItem records"
    updated_count
  end

  def migrate_offering_ingredients(from_ingredient_ids, to_ingredient_id)
    updated_count = OfferingIngredient
      .where(ingredient_id: from_ingredient_ids)
      .update_all(ingredient_id: to_ingredient_id)

    Rails.logger.info "#{LOG_PREFIX} Migrated #{updated_count} OfferingIngredient records"
    updated_count
  end

  def migrate_user_ingredient_preferences(from_ingredient_ids, to_ingredient_id)
    migrated = 0
    conflicted = 0

    from_ingredient_ids.each do |from_id|
      preferences = UserIngredientPreference.where(ingredient_id: from_id)

      preferences.find_each do |preference|
        # Check if user already has preference for canonical ingredient
        existing = UserIngredientPreference.find_by(
          user_id: preference.user_id,
          ingredient_id: to_ingredient_id,
          packaging_form: preference.packaging_form,
          preparation_style: preference.preparation_style
        )

        if existing
          # Conflict: Merge usage data, keep most-used preferred_brand
          handle_preference_conflict(existing, preference)
          preference.destroy
          conflicted += 1
        else
          # No conflict: Simple migration
          preference.update_column(:ingredient_id, to_ingredient_id)
          migrated += 1
        end
      end
    end

    Rails.logger.info "#{LOG_PREFIX} Migrated #{migrated} UserIngredientPreference records"
    Rails.logger.info "#{LOG_PREFIX} Merged #{conflicted} conflicting UserIngredientPreference records"

    [migrated, conflicted]
  end

  def handle_preference_conflict(existing, duplicate)
    # Merge strategy: Sum usage counts, keep most recent last_used_at, keep higher usage_count's brand
    # Ensure we keep a non-nil brand if one exists
    preferred_brand = if duplicate.usage_count > existing.usage_count
      duplicate.preferred_brand || existing.preferred_brand
    else
      existing.preferred_brand || duplicate.preferred_brand
    end

    existing.update_columns(
      preferred_brand: preferred_brand,
      usage_count: existing.usage_count + duplicate.usage_count,
      last_used_at: [existing.last_used_at, duplicate.last_used_at].compact.max
    )
  end

  def delete_duplicate_ingredients(duplicate_ids)
    deleted_count = Ingredient.where(id: duplicate_ids).delete_all

    Rails.logger.info "#{LOG_PREFIX} Deleted #{deleted_count} duplicate ingredient records"
    deleted_count
  end

  def log_consolidation_stats(stats)
    Rails.logger.info "#{LOG_PREFIX} Canonical: #{stats[:canonical_name]} (ID: #{stats[:canonical_id]})"
    Rails.logger.info "#{LOG_PREFIX}   - Recipe ingredients updated: #{stats[:recipe_ingredients]}"
    Rails.logger.info "#{LOG_PREFIX}   - Shopping list items updated: #{stats[:shopping_list_items]}"
    Rails.logger.info "#{LOG_PREFIX}   - Offering ingredients updated: #{stats[:offering_ingredients]}"
    Rails.logger.info "#{LOG_PREFIX}   - User preferences migrated: #{stats[:user_preferences_migrated]}"
    Rails.logger.info "#{LOG_PREFIX}   - User preferences merged: #{stats[:user_preferences_merged]}"
    Rails.logger.info "#{LOG_PREFIX}   - Duplicates removed: #{stats[:duplicate_count]}"
  end
end
