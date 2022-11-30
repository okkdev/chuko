defmodule Chuko.Api.Ricardo do
  @behaviour Chuko.Api.Platform
  require Logger

  @url_item "https://www.ricardo.ch/de/a/"
  @url_api "https://www.ricardo.ch/api/mfa/search/"

  alias Chuko.Structs.Item

  @impl true
  def search(query, session_id) when is_binary(query) do
    options = [
      params: [
        page: 1
      ],
      headers: [
        user_agent: Chuko.AgentUser.get()
      ],
      max_retries: 2
    ]

    amount =
      (@url_api <> query)
      |> URI.encode()
      |> Req.get!()
      |> then(fn %Req.Response{body: body} -> body["totalArticlesCount"] end)

    pages =
      ceil(amount / 60)
      # Capping for rate limit reasons
      |> then(&if &1 > 10, do: 10, else: &1)

    1..pages
    |> Task.async_stream(
      fn page ->
        (@url_api <> query)
        |> URI.encode()
        |> Req.get!(put_in(options[:params][:page], page))
        |> then(fn %Req.Response{body: body} -> body["results"] end)
      end,
      timeout: 300_000
    )
    |> Stream.flat_map(fn {:ok, res} -> res end)
    |> Stream.filter(&(&1["isPromo"] == false))
    |> Enum.map(&cast_item/1)
  rescue
    err ->
      Logger.error(Exception.format(:error, err, __STACKTRACE__))

      Phoenix.PubSub.broadcast!(
        Chuko.PubSub,
        session_id,
        {:search_failed, %{platform: "Ricardo"}}
      )

      []
  end

  defp cast_item(json) do
    %Item{
      id: "ricardo-#{json["id"]}",
      name: json["title"],
      description: "Open the Ricardo offer to read the description...",
      currency: "CHF",
      price: parse_price(json),
      offer_type: parse_offer_type(json),
      images: format_image_url(json["image"]),
      url: "#{@url_item}#{json["id"]}",
      location: "CH",
      platform: :ricardo,
      platform_logo: "/images/ricardo_logo.svg",
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
