defmodule Chuko.Api.FacebookMarketplace do
  @behaviour Chuko.Api.Platform
  require Logger

  @url_item "https://www.facebook.com/marketplace/item/"
  @url_api "https://www.facebook.com/api/graphql/"

  alias Chuko.Structs.Item

  @impl true
  def search(query, session_id) when is_binary(query) do
    options = [
      headers: [
        user_agent: Chuko.AgentUser.get(),
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin"
      ],
      form: [
        fb_dtsg: "your fb token",
        doc_id: "6300438633305058",
        variables:
          %{
            count: 24,
            cursor: nil,
            params: %{
              bqf: %{
                callsite: "COMMERCE_MKTPLACE_WWW",
                query: query
              },
              browse_request_params: %{
                commerce_enable_local_pickup: true,
                commerce_enable_shipping: true,
                commerce_search_and_rp_available: true,
                commerce_search_and_rp_category_id: [],
                commerce_search_and_rp_condition: nil,
                commerce_search_and_rp_ctime_days: nil,
                filter_location_latitude: 47.5667,
                filter_location_longitude: 7.6,
                filter_price_lower_bound: 0,
                filter_price_upper_bound: 214_748_364_700,
                filter_radius_km: 250
              },
              custom_request_params: %{
                browse_context: nil,
                contextual_filters: [],
                referral_code: nil,
                saved_search_strid: nil,
                search_vertical: "C2C",
                seo_url: nil,
                surface: "SEARCH",
                virtual_contextual_filters: []
              }
            },
            scale: 1
          }
          |> Jason.encode!()
      ],
      max_retries: 2
    ]

    @url_api
    |> Req.post!(options)
    |> then(fn %Req.Response{body: body} ->
      Jason.decode!(body)["data"]["marketplace_search"]["feed_units"]["edges"]
    end)
    |> Enum.map(&cast_item(&1["node"]["listing"]))
  rescue
    err ->
      Logger.error(Exception.format(:error, err, __STACKTRACE__))

      Phoenix.PubSub.broadcast!(
        Chuko.PubSub,
        session_id,
        {:search_failed, %{platform: "Facebook Marketplace"}}
      )

      []
  end

  defp cast_item(json) do
    %Item{
      id: "facebook-#{json["id"]}",
      name: json["marketplace_listing_title"],
      description: "Open the Facebook Marketplace listing to read the description...",
      currency: "CHF",
      price: json["listing_price"]["amount"] |> Float.parse() |> elem(0),
      offer_type: :buynow,
      images: [json["primary_listing_photo"]["image"]["uri"]],
      url: @url_item <> json["id"],
      location: json["location"]["reverse_geocode"]["city_page"]["display_name"],
      platform: :facebook,
      platform_logo: "/images/facebook_logo.svg",
      created_at: DateTime.from_unix!(0)
    }
  end
end
