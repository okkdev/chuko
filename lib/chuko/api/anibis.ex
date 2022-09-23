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
        numberOfResults: 100
      ],
      headers: [
        user_agent: "Mozilla/5.0 (X11; Linux x86_64; rv:5.0) Gecko/20131221 Firefox/36.0"
      ]
    ]

    @url_api
    |> Req.get!(options)
    |> parse_response()
  end

  defp parse_response(%Req.Response{body: body}) do
    body["listings"]
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

  defp format_image_urls(base_url, urls) do
    Enum.map(urls, &(base_url <> String.replace(&1, "[size]", "1024x768/3/60")))
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
