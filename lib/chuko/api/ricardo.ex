defmodule Chuko.Api.Ricardo do
  @behaviour Chuko.Api.Platform

  @url_item "https://www.ricardo.ch/de/a/"
  @url_api "https://www.ricardo.ch/api/mfa/search/"

  alias Chuko.Structs.Item

  @impl true
  def search(query) when is_binary(query) do
    options = [
      params: [
        page: 1
      ],
      headers: [
        user_agent: "Mozilla/5.0 (X11; Linux x86_64; rv:5.0) Gecko/20131221 Firefox/36.0"
      ]
    ]

    amount =
      (@url_api <> query)
      |> URI.encode()
      |> Req.get!()
      |> then(fn %Req.Response{body: body} -> body["totalArticlesCount"] end)

    pages = ceil(amount / 60)

    1..pages
    |> Task.async_stream(fn page ->
      (@url_api <> query)
      |> URI.encode()
      |> Req.get!(put_in(options[:params][:page], page))
      |> then(fn %Req.Response{body: body} -> body["results"] end)
    end)
    |> Stream.flat_map(fn {:ok, res} -> res end)
    |> Stream.filter(&(&1["isPromo"] == false))
    |> Enum.map(&cast_item/1)
  end

  defp cast_item(json) do
    %Item{
      id: json["id"],
      name: json["title"],
      description: json["title"],
      currency: "CHF",
      price: parse_price(json),
      offer_type: parse_offer_type(json),
      images: format_image_url(json["image"]),
      url: "#{@url_item}#{json["id"]}",
      location: "CH",
      platform: Ricardo,
      created_at: parse_datetime(json["startDate"])
    }
  end

  defp parse_price(%{"hasAuction" => true} = json), do: json["bidPrice"] / 1
  defp parse_price(json), do: json["buyNowPrice"] / 1

  defp parse_offer_type(%{"hasAuction" => true}), do: :auction
  defp parse_offer_type(_), do: :buynow

  defp format_image_url(url) do
    url
    |> String.replace("{{TRANSFORMATION}}", "t_1000x750")
    |> List.wrap()
  end

  defp parse_datetime(datetime) do
    case DateTime.from_iso8601(datetime) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end
end
