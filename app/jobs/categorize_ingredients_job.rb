# app/jobs/categorize_ingredients_job.rb
class CategorizeIngredientsJob < ApplicationJob
  queue_as :default
  
  BATCH_SIZE = 75

  def perform
    Rails.logger.info "Starting ingredient categorization..."
    
    category_map = load_category_map
    uncategorized = fetch_uncategorized_ingredients
    
    if uncategorized.empty?
      Rails.logger.info "No uncategorized ingredients found."
      return
    end
    
    Rails.logger.info "Found #{uncategorized.length} uncategorized ingredients."
    
    process_batches(uncategorized, category_map)
    
    Rails.logger.info "Categorization complete!"
  end

  private

  def load_category_map
    IngredientCategory.pluck(:name, :id).to_h
  end

  def fetch_uncategorized_ingredients
    Ingredient.where(ingredient_category_id: nil)
              .pluck(:id, :name, :packaging_form, :preparation_style)
  end

  def process_batches(uncategorized, category_map)
    uncategorized.each_slice(BATCH_SIZE).with_index do |batch, index|
      ingredient_data = batch.map { |id, name, packaging, preparation| 
        { 
          name: name, 
          packaging: packaging, 
          preparation: preparation 
        } 
      }
      
      Rails.logger.info "Processing batch #{index + 1} (#{ingredient_data.length} ingredients)..."
      
      begin
        categorizations = call_claude_api(ingredient_data)
        update_database(categorizations, category_map)
        Rails.logger.info "✓ Categorized #{categorizations.length} ingredients"
      rescue StandardError => e
        Rails.logger.error "✗ Batch #{index + 1} failed: #{e.message}"
        # Continue to next batch instead of failing entire job
      end
    end
  end

  def call_claude_api(ingredient_data)
    prompt = build_prompt(ingredient_data)
    client = ClaudeApiClient.new
    response_text = client.send_message(prompt)
    
    # Strip markdown formatting if present
    response_text = response_text.gsub(/```json\n?/, '').gsub(/```/, '').strip
    
    JSON.parse(response_text)
  end

  def build_prompt(ingredient_data)
    <<~PROMPT
      Categorize these ingredients into grocery store sections. Return ONLY valid JSON.

      Categories: Fresh Produce, Proteins, Dairy & Eggs, Pantry Staples, Spices & Herbs, Baking Supplies, Condiments & Sauces, Frozen, Beverages, Specialty

      IMPORTANT CATEGORIZATION NOTES:
      - Consider packaging form (fresh, canned, frozen, dried) when categorizing
      - Consider preparation style (whole, diced, crushed, chopped, sliced, minced, ground, shredded, grated, cubed, cooked) when categorizing
      - "frozen" packaging should typically go in Frozen category
      - "canned" packaging should typically go in Pantry Staples unless it's a protein
      - "fresh" packaging should typically go in Fresh Produce or Proteins depending on the ingredient
      - Base category should match the ingredient's form and typical storage location

      Format: {"ingredient_name": "category"}

      Ingredients (with packaging and preparation details):
      #{JSON.pretty_generate(ingredient_data)}

      IMPORTANT:
      - Return ONLY the JSON object with ingredient names as keys (not the full object)
      - Use exact category names from the list above
      - No markdown, no explanation, just JSON
      - Key should be just the ingredient name (e.g., "tomatoes" not the full object)
    PROMPT
  end

  def update_database(categorizations, category_map)
    categorizations.each do |ingredient_name, category_name|
      category_id = category_map[category_name]
      
      if category_id.nil?
        Rails.logger.warn "Unknown category '#{category_name}' for '#{ingredient_name}'"
        next
      end
      
      Ingredient.where(name: ingredient_name).update_all(
        ingredient_category_id: category_id,
        categorized_by: 'ai',
        categorized_at: Time.current
      )
    end
  end
end
