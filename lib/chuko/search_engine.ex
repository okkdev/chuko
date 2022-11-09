defmodule Chuko.SearchEngine do
  alias Chuko.Api.Platform

  @platforms [Tutti, Anibis, Ricardo]

  def search_platforms(query, opts \\ @platforms) when is_binary(query) and is_list(opts) do
    opts
    |> Task.async_stream(fn platform ->
      Module.safe_concat([Chuko.Api, platform])
      |> Platform.search(query)
    end)
    |> Enum.flat_map(fn {:ok, res} -> res end)
    |> Enum.sort_by(& &1.created_at, {:desc, DateTime})
  end
end
