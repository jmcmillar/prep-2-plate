class UserIngredientPreference < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :ingredient

  # Validations
  validates :user, presence: true
  validates :ingredient, presence: true
  validates :preferred_brand, presence: true
  validates :user_id, uniqueness: {
    scope: [:ingredient_id, :packaging_form, :preparation_style],
    message: "has already been taken"
  }
  validates :packaging_form,
            inclusion: { in: Ingredient::PACKAGING_FORMS.keys.map(&:to_s), allow_nil: true },
            if: :packaging_form_present?
  validates :preparation_style,
            inclusion: { in: Ingredient::PREPARATION_STYLES.keys.map(&:to_s), allow_nil: true },
            if: :preparation_style_present?

  # Callbacks
  before_validation :set_last_used_at, on: :create

  # Scopes
  scope :for_user, ->(user) { where(user: user) }
  scope :for_ingredient, ->(ingredient) { where(ingredient: ingredient) }
  scope :most_used, -> { order(usage_count: :desc) }
  scope :recently_used, -> { order(last_used_at: :desc) }
  scope :matching, ->(ingredient_id, packaging_form, preparation_style) {
    where(
      ingredient_id: ingredient_id,
      packaging_form: packaging_form,
      preparation_style: preparation_style
    )
  }

  # Class Methods
  def self.find_best_match(user_id, ingredient_id, packaging_form, preparation_style)
    # Try exact match first
    exact = for_user(User.find(user_id))
            .matching(ingredient_id, packaging_form, preparation_style)
            .first
    return exact if exact.present?

    # Try packaging-only match
    packaging_match = for_user(User.find(user_id))
                      .matching(ingredient_id, packaging_form, nil)
                      .first
    return packaging_match if packaging_match.present?

    # Try preparation-only match
    prep_match = for_user(User.find(user_id))
                 .matching(ingredient_id, nil, preparation_style)
                 .first
    return prep_match if prep_match.present?

    # Try generic match (no packaging or prep)
    generic = for_user(User.find(user_id))
              .matching(ingredient_id, nil, nil)
              .first
    return generic if generic.present?

    # No match found
    nil
  end

  def self.ransackable_attributes(auth_object = nil)
    ["user_id", "ingredient_id", "packaging_form", "preparation_style", "preferred_brand"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "ingredient"]
  end

  # Instance Methods
  def record_usage!
    increment!(:usage_count)
    touch(:last_used_at)
  end

  def display_context
    parts = []
    parts << Ingredient::PACKAGING_FORMS[packaging_form.to_sym] if packaging_form.present?
    parts << Ingredient::PREPARATION_STYLES[preparation_style.to_sym] if preparation_style.present?
    parts << ingredient.name
    parts.join(" ")
  end

  private

  def packaging_form_present?
    packaging_form.present?
  end

  def preparation_style_present?
    preparation_style.present?
  end

  def set_last_used_at
    self.last_used_at ||= Time.current
  end
end
