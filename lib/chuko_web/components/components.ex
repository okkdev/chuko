defmodule ChukoWeb.Components do
  use Phoenix.Component

  def item(assigns) do
    ~H"""
    <div
      id={"item-#{@item.id}"}
      class="relative flex flex-col overflow-hidden bg-white border border-gray-200 shadow-xl rounded-lg group"
    >
      <div class="shadow-sm aspect-w-3 overflow-hidden rounded-lg h-96">
        <%= case Enum.count(@item.images) do %>
          <% 0 -> %>
            <div class="flex h-full justify-center items-center">
              <Heroicons.photo class="text-gray-300 h-8 w-8" />
            </div>
          <% 1 -> %>
            <img
              src={hd(@item.images)}
              class="object-cover object-center w-full h-full"
              alt={"Image of #{@item.name}"}
            />
          <% _ -> %>
            <.carousel item={@item} />
        <% end %>
      </div>
      <div class="flex flex-col justify-between h-56 p-4 space-y-2">
        <div class="space-y-0.5">
          <h3 class="text-base font-medium text-gray-900 line-clamp-2">
            <a href={@item.url} target="_blank">
              <%= @item.name %>
            </a>
          </h3>
          <p class="text-sm text-gray-500 line-clamp-3">
            <%= @item.description %>
          </p>
        </div>
        <div class="grid grid-cols-2 gap-2">
          <p class="text-base font-medium text-gray-900"><%= inspect(@item.offer_type) %></p>
          <p class="text-base font-medium text-gray-900">
            <%= "#{@item.currency}" %>
            <span class="text-lg font-bold">
              <%= "#{:erlang.float_to_binary(@item.price, decimals: 2)}" %>
            </span>
          </p>
          <img class="w-2/3" src={@item.platform_logo} alt={inspect(@item.platform)} />
          <p class="text-sm text-gray-500"><%= @item.location %></p>
        </div>
      </div>
    </div>
    """
  end

  attr :query, :string, required: true
  attr :disabled, :string, required: true
  attr :rest, :global

  def search_bar(assigns) do
    ~H"""
    <form class="w-full transform bg-white rounded-xl divide-y divide-gray-100 shadow-xl" {@rest}>
      <div class="relative">
        <Heroicons.magnifying_glass
          solid
          class="pointer-events-none absolute top-3.5 left-4 h-5 w-5 text-gray-400"
        />
        <input
          type="text"
          class="w-full h-12 pr-4 pl-11 text-gray-800 rounded-xl placeholder-gray-400 bg-transparent border-0 ring-1 ring-black ring-opacity-5 focus:border-pink-300 focus:outline-none focus:ring-pink-300 sm:text-sm "
          placeholder="Search..."
          name="query"
          id="query"
          disabled={@disabled}
          value={if assigns[:query], do: @query, else: ""}
        />
      </div>
    </form>
    """
  end

  def carousel(assigns) do
    ~H"""
    <div
      id={"image-carousel-#{@item.id}"}
      class="relative w-full h-full"
      phx-hook="Carousel"
      phx-update="ignore"
      data-carousel-page={0}
      data-carousel-pages={Enum.count(@item.images)}
    >
      <%!-- Carousel wrapper --%>
      <div class="w-full h-full" data-carousel-body>
        <img
          :for={{image, index} <- Enum.with_index(@item.images)}
          src={image}
          class="hidden object-cover object-center w-full h-full"
          alt={"Image ##{index + 1} of #{@item.name}"}
        />
      </div>
      <%!-- Slider indicators --%>
      <div
        class="absolute z-30 pointer-events-none flex space-x-3 bottom-5 opacity-80 left-1/2 -translate-x-1/2"
        data-slide-indicators
      >
        <div
          :for={_ <- @item.images}
          class="w-3 h-3 bg-white ring-1 ring-black ring-opacity-20 rounded-full transition opacity-30"
        >
        </div>
      </div>
      <%!-- Slider controls --%>
      <div class="absolute top-0 left-0 z-30 h-full w-full flex">
        <button
          type="button"
          class="flex items-center justify-start px-5 h-full w-full cursor-pointer group transition focus:outline-none hover:bg-white/20"
          data-carousel-prev
        >
          <Heroicons.chevron_left class="w-5 h-5 text-white sm:w-6 sm:h-6" />
          <span class="sr-only">Previous</span>
        </button>
        <button
          type="button"
          class="flex items-center justify-end px-5 h-full w-full cursor-pointer group transition focus:outline-none hover:bg-white/20"
          data-carousel-next
        >
          <Heroicons.chevron_right class="w-5 h-5 text-white sm:w-6 sm:h-6" />
          <span class="sr-only">Next</span>
        </button>
      </div>
    </div>
    """
  end

  def loading(assigns) do
    ~H"""
    <div class="flex items-center justify-center">
      <Heroicons.arrow_path class="text-gray-400 w-20 h-20 animate-spin drop-shadow-xl" />
    </div>
    """
  end
end
