json.firstName Current.user.first_name
json.lastName Current.user.last_name
json.email Current.user.email
json.imageUrl Current.user.image.attached? ?  rails_blob_url(Current.user.image, host: request.host_with_port) : image_url("no-recipe-image.png", host: request.host_with_port)
