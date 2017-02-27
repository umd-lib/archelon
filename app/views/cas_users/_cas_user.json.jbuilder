json.extract! cas_user, :id, :cas_directory_id, :name, :admin, :created_at, :updated_at
json.url cas_user_url(cas_user, format: :json)
