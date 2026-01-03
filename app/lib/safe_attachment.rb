# SafeAttachment wraps an ActiveStorage attachment and guarantees safe access.
# Always returns the attachment object if attached, or fallback string if not.
#
# Usage in facade:
#   safe_attachment(recipe.image, 'no-recipe-image.png').url
#   # Returns attachment object or fallback string
#
class SafeAttachment
  def initialize(attachment, fallback = "")
    @attachment = attachment
    @fallback = fallback
  end

  # Returns the attachment if attached, otherwise returns fallback
  def url
    return @fallback unless attached?

    @attachment
  rescue ActiveStorage::FileNotFoundError, NoMethodError
    @fallback
  end

  # Always responds to attached?
  def attached?
    @attachment.respond_to?(:attached?) && @attachment.attached?
  end
end
