defmodule Chuko.Structs.Item do
  defstruct [
    :id,
    :name,
    :description,
    :currency,
    :price,
    :offer_type,
    :images,
    :url,
    :location,
    :platform,
    :platform_logo,
    :created_at
  ]
end
