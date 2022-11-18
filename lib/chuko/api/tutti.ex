defmodule Chuko.Api.Tutti do
  @moduledoc """
  DEPRECATED
  Should switch to the new GraphQL API sometime
  """
  @behaviour Chuko.Api.Platform

  @url_image "https://c.tutti.ch/images/"
  @url_item "https://www.tutti.ch/de/vi/"
  @url_api "https://www.tutti.ch/api/v10/list.json"

  alias Chuko.Structs.Item

  @impl true
  def search(query) when is_binary(query) do
    options = [
      params: [
        q: query,
        # page
        # o: 1,
        # type offer
        st: "s",
        # limited to 3000 even when switching pages
        limit: 3000,
        with_all_regions: true,
        with_neighbouring_regions: false
      ],
      headers: [
        user_agent: "Mozilla/5.0 (X11; Linux x86_64; rv:5.0) Gecko/20131221 Firefox/36.0",
        "x-tutti-hash": Ecto.UUID.generate()
      ],
      max_retries: 2,
      cache: true
    ]

    @url_api
    |> Req.get!(options)
    |> then(fn %Req.Response{body: body} -> body["items"] end)
    |> Enum.map(&cast_item/1)
  end

  defp cast_item(json) do
    %Item{
      id: json["id"],
      name: json["subject"],
      description: json["body"],
      currency: "CHF",
      price: parse_price(json["price"]),
      offer_type: :buynow,
      images: Enum.map(json["image_names"], &(@url_image <> &1)),
      url: @url_item <> json["slug"]["de"],
      location: json["location_info"]["region_name"],
      platform: Tutti,
      created_at: parse_datetime(json["epoch_time"])
    }
  end

  defp parse_price(string) do
    string
    |> String.trim()
    |> String.replace("'", "")
    |> Integer.parse()
    |> case do
      {price, _} -> price / 1
      :error -> 0.0
    end
  end

  defp parse_datetime(epoch) do
    case DateTime.from_unix(epoch) do
      {:ok, dt} -> dt
      _ -> nil
    end
  end
end
