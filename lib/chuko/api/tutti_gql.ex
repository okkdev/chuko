defmodule Chuko.Api.TuttiGql do
  @moduledoc """
  Unfinished GraphQL Tutti API client.

  # Some notes:
  url:
  `https://www.tutti.ch/api/v10/graphql`

  needed header:
  `x-tutti-client-identifier: web/1337.69+please-dont-block-me`

  This is the query:
  ```
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
      __typename
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
  ```

  Here are the variables:
  ```
  {
    "query": "nintendo",
    "constraints": null,
    "category": null,
    "first": 100,
    "offset": 3000,
    "direction": "DESCENDING",
    "sort": "TIMESTAMP"
  }
  ```
  """
end
