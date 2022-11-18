defmodule Chuko.SearchEngine do
  alias Chuko.Api.Platform

  @platforms [Tutti, Anibis, Ricardo]

  def search_platforms(query, platforms \\ @platforms)
      when is_binary(query) and is_list(platforms) do
    Task.Supervisor.async_stream_nolink(
      Chuko.SearchSupervisor,
      platforms,
      fn platform ->
        Module.safe_concat([Chuko.Api, platform])
        |> Platform.search(query)
      end,
      timeout: 300_000
    )
    |> Stream.filter(&(elem(&1, 0) == :ok))
    |> Enum.flat_map(fn {:ok, res} -> res end)
  end
end
