defmodule Chuko.Api.TuttiGql do
  @moduledoc """
  The new GraphQL API
  """
  @behaviour Chuko.Api.Platform

  @query """
  query SearchListings($query: String, $constraints: ListingSearchConstraints, $category: ID, $first: Int!, $offset: Int!, $sort: ListingSortMode!, $direction: SortDirection!) {
    searchListingsByQuery(
      query: $query
      constraints: $constraints
      category: $category
    ) {
      ...searchResultFields
    }
  }

  fragment searchResultFields on ListingSearchResult {
    listings(first: $first, offset: $offset, sort: $sort, direction: $direction) {
      ...listingsConnectionField
    }
    filters {
      ...filterFields
    }
    suggestedCategories {
      ...suggestedCategoryFields
    }
    selectedCategory {
      ...selectedCategoryFields
    }
  }

  fragment listingsConnectionField on ListingsConnection {
    totalCount
    edges {
      node {
        ...listingFields
      }
    }
    placements {
      keyValues {
        key
        value
      }
      pageName
      pagePath
      positions {
        adUnitID
        mobile
        position
        positionType
      }
      afs {
        customChannelID
        styleID
        adUnits {
          adUnitID
          mobile
        }
      }
    }
  }

  fragment listingFields on Listing {
    listingID
    title
    body
    postcodeInformation {
      postcode
      locationName
      canton {
        shortName
        name
      }
    }
    timestamp
    formattedPrice
    formattedSource
    highlighted
    sellerInfo {
      alias
      logo {
        rendition {
          src
        }
      }
    }
    images(first: 15) {
      rendition {
        src
      }
    }
    thumbnail {
      normalRendition: rendition(width: 235, height: 167) {
        src
      }
      retinaRendition: rendition(width: 470, height: 334) {
        src
      }
    }
    seoInformation {
      deSlug: slug(language: DE)
      frSlug: slug(language: FR)
      itSlug: slug(language: IT)
    }
  }

  fragment filterFields on ListingFilter {
    __typename
    ...nonGroupFilterFields
  }

  fragment nonGroupFilterFields on ListingFilter {
    ...filterDescriptionFields
    ... on ListingIntervalFilter {
      ...intervalFilterFields
    }
    ... on ListingSingleSelectFilter {
      ...singleSelectFilterFields
    }
    ... on ListingMultiSelectFilter {
      ...multiSelectFilterFields
    }
    ... on ListingPricingFilter {
      ...pricingFilterFields
    }
    ... on ListingLocationFilter {
      ...locationFilterFields
    }
  }

  fragment filterDescriptionFields on ListingsFilterDescription {
    name
    label
    disabled
  }

  fragment intervalFilterFields on ListingIntervalFilter {
    ...filterDescriptionFields
    intervalType {
      __typename
      ... on ListingIntervalTypeText {
        ...intervalTypeTextFields
      }
      ... on ListingIntervalTypeSlider {
        ...intervalTypeSliderFields
      }
    }
    intervalValue: value {
      min
      max
    }
    step
    unit
    minField {
      placeholder
    }
    maxField {
      placeholder
    }
  }

  fragment intervalTypeTextFields on ListingIntervalTypeText {
    minLimit
    maxLimit
  }

  fragment intervalTypeSliderFields on ListingIntervalTypeSlider {
    sliderStart: minLimit
    sliderEnd: maxLimit
  }

  fragment singleSelectFilterFields on ListingSingleSelectFilter {
    ...filterDescriptionFields
    ...selectFilterFields
    selectedOption: value
  }

  fragment selectFilterFields on ListingSelectFilter {
    options {
      ...selectOptionFields
    }
    placeholder
    inline
  }

  fragment selectOptionFields on ListingSelectOption {
    value
    label
  }

  fragment multiSelectFilterFields on ListingMultiSelectFilter {
    ...filterDescriptionFields
    ...selectFilterFields
    selectedOptions: values
  }

  fragment pricingFilterFields on ListingPricingFilter {
    ...filterDescriptionFields
    pricingValue: value {
      min
      max
      freeOnly
    }
    minField {
      placeholder
    }
    maxField {
      placeholder
    }
  }

  fragment locationFilterFields on ListingLocationFilter {
    ...filterDescriptionFields
    value {
      radius
      selectedLocalities {
        ...localityFields
      }
    }
  }

  fragment localityFields on Locality {
    localityID
    name
    localityType
  }

  fragment suggestedCategoryFields on Category {
    categoryID
    label
    searchToken
    mainImage {
      rendition(width: 300) {
        src
      }
    }
  }

  fragment selectedCategoryFields on Category {
    categoryID
    label
    ...categoryParent
  }

  fragment categoryParent on Category {
    parent {
      categoryID
      label
      parent {
        categoryID
        label
        parent {
          categoryID
          label
        }
      }
    }
  }
  """

  @url_item "https://www.tutti.ch/de/vi/"
  @url_api "https://www.tutti.ch/api/v10/graphql"

  alias Chuko.Structs.Item

  @impl true
  def search(query) when is_binary(query) do
    options = [
      json: %{
        query: @query,
        variables: %{
          query: query,
          constraints: nil,
          category: nil,
          first: 100,
          # max 3000
          offset: 0,
          direction: "DESCENDING",
          sort: "TIMESTAMP"
        }
      },
      headers: [
        user_agent: "Mozilla/5.0 (X11; Linux x86_64; rv:5.0) Gecko/20131221 Firefox/36.0",
        "Content-Type": "application/json",
        # let's see how long this works
        "x-tutti-client-identifier": "web/1337.69+please-dont-block-me-uwu"
      ],
      max_retries: 2,
      cache: true
    ]

    # could be optimized by using the body
    amount =
      Req.post!(@url_api, put_in(options[:json][:variables][:first], 1))
      |> then(fn %Req.Response{body: body} ->
        body["data"]["searchListingsByQuery"]["listings"]["totalCount"]
      end)
      |> then(&if &1 > 3000, do: 3000, else: &1)

    0..floor(amount / 100)
    |> Enum.map(&(&1 * 100))
    |> Task.async_stream(
      fn offset ->
        Req.post!(@url_api, put_in(options[:json][:variables][:offset], offset))
        |> then(fn %Req.Response{body: body} ->
          body["data"]["searchListingsByQuery"]["listings"]["edges"]
        end)
      end,
      timeout: 300_000
    )
    |> Stream.flat_map(fn {:ok, res} -> List.wrap(res) end)
    |> Enum.filter(&(not is_nil(&1)))
    |> Enum.map(&cast_item(&1["node"]))
  end

  defp cast_item(json) do
    %Item{
      id: json["listingID"],
      name: json["title"],
      description: json["body"],
      currency: "CHF",
      price: parse_price(json["formattedPrice"]),
      offer_type: :buynow,
      images: Enum.map(json["images"], & &1["rendition"]["src"]),
      url: @url_item <> json["seoInformation"]["deSlug"],
      location: json["postcodeInformation"]["canton"]["name"],
      platform: Tutti,
      created_at: DateTime.from_iso8601(json["timestamp"]) |> then(fn {:ok, dt, _} -> dt end)
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
end
