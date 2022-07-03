defmodule Chuko.Api.Tutti do
  @url_image "https://c.tutti.ch/images/"
  @url_item "https://www.tutti.ch/de/vi/"
  @url_api "https://www.tutti.ch/api/v10/list.json"

  alias Chuko.Structs.Item

  def search(query) when is_binary(query) do
    options = [
      params: [
        q: query,
        limit: 100,
        with_all_regions: true,
        with_neighbouring_regions: false
      ],
      headers: [
        user_agent: "Mozilla/5.0 (X11; Linux x86_64; rv:5.0) Gecko/20131221 Firefox/36.0",
        "x-tutti-hash": Ecto.UUID.generate()
      ]
    ]

    @url_api
    |> Req.get!(options)
    |> parse_response()
  end

  defp parse_response(%Req.Response{body: body}) do
    body["items"]
    |> Enum.map(&parse_item/1)
  end

  defp parse_item(json) do
    %Item{
      id: json["id"],
      name: json["subject"],
      description: json["body"],
      price: json["price"],
      images: Enum.map(json["image_names"], &(@url_image <> &1)),
      url: @url_item <> json["slug"]["de"],
      location: json["location_info"]["region_name"],
      platform: :tutti,
      created_at: json["epoch_time"]
    }
  end
end
