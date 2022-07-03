defmodule Chuko.SearchEngine do
  alias Chuko.Api.Tutti

  def search_platforms(query, opts \\ [:tutti]) when is_binary(query) and is_list(opts) do
    Enum.flat_map(opts, &search(query, &1))
  end

  defp search(query, :tutti) do
    Tutti.search(query)
  end
end
