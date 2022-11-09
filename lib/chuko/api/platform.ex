defmodule Chuko.Api.Platform do
  alias Chuko.Structs.Item

  @callback search(String.t()) :: [%Item{}]

  def search(platform, query) do
    platform.search(query)
  end
end
