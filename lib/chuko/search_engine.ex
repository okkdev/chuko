defmodule Chuko.SearchEngine do
  alias Chuko.Api.Platform

  @platforms [TuttiGql, Ricardo]

  def search_platforms(query, session_id, platforms \\ @platforms)
      when is_binary(query) and is_list(platforms) do
    items =
      Task.Supervisor.async_stream_nolink(
        Chuko.SearchSupervisor,
        platforms,
        fn platform ->
          Module.safe_concat([Chuko.Api, platform])
          |> Platform.search(query, session_id)
        end,
        timeout: 30_000
      )
      |> Stream.filter(&(elem(&1, 0) == :ok))
      |> Enum.flat_map(fn {:ok, res} -> res end)

    Phoenix.PubSub.broadcast!(
      Chuko.PubSub,
      session_id,
      {:items_found, %{items: items}}
    )
  end
end
