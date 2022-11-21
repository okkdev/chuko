defmodule Chuko.Api.Anibis do
  @behaviour Chuko.Api.Platform

  @url_item "https://www.anibis.ch"
  @url_api "https://api.anibis.ch/v4/de/search/listings"

  alias Chuko.Structs.Item

  @impl true
  def search(query) when is_binary(query) do
    options = [
      params: [
        cun: "alle-kategorien",
        fcun: "alle-kategorien",
        fts: query,
        # page size
        ps: 120,
        # page index
        pi: 1
      ],
      headers: [
        user_agent: Chuko.AgentUser.get()
      ],
      max_retries: 2,
      cache: true
    ]

    amount =
      @url_api
      |> Req.get!(put_in(options[:params][:ps], 1))
      |> then(fn %Req.Response{body: body} -> body["pagingInfo"]["totalItems"] end)

    pages = ceil(amount / 120)

    1..pages
    |> Task.async_stream(
      fn page ->
        @url_api
        |> Req.get!(put_in(options[:params][:pi], page))
        |> then(fn %Req.Response{body: body} -> body["listings"] end)
      end,
      timeout: 300_000
    )
    |> Stream.flat_map(fn {:ok, res} -> res end)
    |> Enum.map(&cast_item/1)
  end

  defp cast_item(json) do
    %Item{
      id: json["id"],
      name: json["title"],
      description: Enum.join(json["detailsExtraLarge"]),
      currency: "CHF",
      price: json["price"],
      offer_type: :buynow,
      images: format_image_urls(json["imageData"]["baseUrl"], json["imageData"]["images"]),
      url: @url_item <> json["staticUrl"],
      location: Enum.join(json["detailsMainSmall"]),
      platform: Anibis,
      created_at: parse_datetime(Enum.fetch!(json["detailsMainLarge"], 2))
    }
  end

  defp format_image_urls(base_url, urls) when is_binary(base_url) and is_list(urls) do
    Enum.map(urls, &(base_url <> String.replace(&1, "[size]", "1024x768/3/60")))
  end

  defp format_image_urls(_, _) do
    []
  end

  defp parse_datetime(date) do
    date
    |> String.split(".")
    |> Enum.reverse()
    |> Enum.join("-")
    |> then(&(&1 <> "T00:00:00Z"))
    |> DateTime.from_iso8601()
    |> case do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end
end
