defmodule Chuko.Api.Platform do
  alias Chuko.Structs.Item

  @callback search(String.t(), String.t()) :: [%Item{}]

  def search(platform, query, session_id) do
    platform.search(query, session_id)
  end
end
