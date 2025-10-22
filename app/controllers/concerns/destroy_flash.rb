module DestroyFlash
  extend ActiveSupport::Concern

  def set_destroy_flash_for(record)
    if record.destroyed?
      flash[:notice] = "#{record.model_name.human} was successfully destroyed."
    else
      flash[:error] = record.errors.full_messages.join(", ")
    end
  end
end
