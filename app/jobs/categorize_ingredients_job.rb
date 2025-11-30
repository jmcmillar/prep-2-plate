# app/jobs/categorize_ingredients_job.rb
require 'net/http'
require 'json'
require 'uri'

class CategorizeIngredientsJob < ApplicationJob
  queue_as :default
  
  BATCH_SIZE = 75
  API_ENDPOINT = "https://api.anthropic.com/v1/messages"
  MODEL = "claude-sonnet-4-20250514"

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
    Ingredient.where(ingredient_category_id: nil).pluck(:id, :name)
  end

  def process_batches(uncategorized, category_map)
    uncategorized.each_slice(BATCH_SIZE).with_index do |batch, index|
      ingredient_names = batch.map { |_, name| name }
      
      Rails.logger.info "Processing batch #{index + 1} (#{ingredient_names.length} ingredients)..."
      
      begin
        categorizations = call_claude_api(ingredient_names)
        update_database(categorizations, category_map)
        Rails.logger.info "✓ Categorized #{categorizations.length} ingredients"
      rescue StandardError => e
        Rails.logger.error "✗ Batch #{index + 1} failed: #{e.message}"
        # Continue to next batch instead of failing entire job
      end
    end
  end

  def call_claude_api(ingredient_names)
    prompt = build_prompt(ingredient_names)
    
    uri = URI.parse(API_ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = ENV['ANTHROPIC_API_KEY']
    request["anthropic-version"] = "2023-06-01"
    
    request.body = JSON.generate({
      model: MODEL,
      max_tokens: 2000,
      messages: [{ role: "user", content: prompt }]
    })

    response = http.request(request)
    
    unless response.is_a?(Net::HTTPSuccess)
      raise "API request failed: #{response.code} #{response.message}"
    end
    
    data = JSON.parse(response.body)
    response_text = data['content'][0]['text']
    
    # Strip markdown formatting if present
    response_text = response_text.gsub(/```json\n?/, '').gsub(/```/, '').strip
    
    JSON.parse(response_text)
  end

  def build_prompt(ingredient_names)
    <<~PROMPT
      Categorize these ingredients into grocery store sections. Return ONLY valid JSON.

      Categories: Fresh Produce, Proteins, Dairy & Eggs, Pantry Staples, Spices & Herbs, Baking Supplies, Condiments & Sauces, Frozen, Beverages, Specialty

      Format: {"ingredient_name": "category"}

      Ingredients:
      #{JSON.pretty_generate(ingredient_names)}

      IMPORTANT:
      - Return ONLY the JSON object
      - Use exact category names from the list above
      - No markdown, no explanation, just JSON
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
