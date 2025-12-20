class Ingredient < ApplicationRecord
  PACKAGING_FORMS = {
    fresh: 'Fresh',
    canned: 'Canned',
    frozen: 'Frozen',
    dried: 'Dried'
  }.freeze

  PREPARATION_STYLES = {
    whole: 'Whole',
    diced: 'Diced',
    crushed: 'Crushed',
    chopped: 'Chopped',
    sliced: 'Sliced',
    minced: 'Minced',
    ground: 'Ground',
    shredded: 'Shredded',
    grated: 'Grated',
    cubed: 'Cubed'
  }.freeze

  validates :name, presence: true
  validates :name, uniqueness: { scope: [:packaging_form, :preparation_style], case_sensitive: false }
  validates :packaging_form,
            inclusion: { in: PACKAGING_FORMS.keys.map(&:to_s), allow_nil: true }
  validates :preparation_style,
            inclusion: { in: PREPARATION_STYLES.keys.map(&:to_s), allow_nil: true }

  belongs_to :ingredient_category, optional: true
  has_many :recipe_ingredients, dependent: :restrict_with_error, inverse_of: :ingredient
  delegate :name, to: :ingredient_category, prefix: true, allow_nil: true
  before_save :downcase_fields

  def downcase_fields
    self.name.downcase!
  end

  # Display name combines packaging + preparation + name
  def display_name
    parts = []
    parts << PACKAGING_FORMS[packaging_form.to_sym] if packaging_form.present?
    parts << PREPARATION_STYLES[preparation_style.to_sym] if preparation_style.present?
    parts << name
    parts.join(" ")
  end

  # Find all variants of a base ingredient
  scope :all_forms_of, ->(base_name) { where(name: base_name.downcase) }

  # Find by packaging form
  scope :with_packaging, ->(form) { where(packaging_form: form.to_s) }

  # Find by preparation style
  scope :with_preparation, ->(style) { where(preparation_style: style.to_s) }

  scope :filtered_by_ingredient_category, ->(category_ids) {
    return all if category_ids.blank?
    where(ingredient_category_id: category_ids)
  }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "packaging_form", "preparation_style"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
