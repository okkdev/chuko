defmodule ChukoWeb.Components do
  use Phoenix.Component

  def item(assigns) do
    ~H"""
    <div
      id={"item-#{Ecto.UUID.generate}"}
      class="relative flex flex-col overflow-hidden bg-white border border-gray-200 rounded-lg group"
    >
      <div class="bg-gray-200 aspect-w-3 aspect-h-4 sm:aspect-none sm:h-96">
        <.carousel item={@item} />
        <%!-- <img
          src={Enum.at(@item.images, 0)}
          alt={@item.name}
          class="object-cover object-center w-full h-full sm:w-full sm:h-full"
        /> --%>
      </div>
      <div class="flex flex-col flex-1 p-4 space-y-2">
        <h3 class="text-sm font-medium text-gray-900">
          <a href={@item.url}>
            <%= @item.name %>
          </a>
        </h3>
        <p class="h-20 overflow-hidden text-sm text-gray-500 text-ellipsis">
          <%= @item.description %>
        </p>
        <div class="flex justify-between">
          <div class="flex flex-col justify-end flex-1">
            <p class="text-sm italic text-gray-500"><%= inspect(@item.platform) %></p>
            <p class="text-base font-medium text-gray-900"><%= inspect(@item.offer_type) %></p>
          </div>
          <div class="flex flex-col justify-end flex-1">
            <p class="text-sm italic text-gray-500"><%= @item.location %></p>
            <p class="text-base font-medium text-gray-900">
              <%= "#{@item.currency} #{@item.price}" %>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :query, :string, required: true
  attr :rest, :global

  def search_bar(assigns) do
    ~H"""
    <form
      class="w-full overflow-hidden transition-all transform bg-white divide-y divide-gray-100 shadow-2xl rounded-xl ring-1 ring-black ring-opacity-5"
      {@rest}
    >
      <div class="relative">
        <Heroicons.magnifying_glass
          solid
          class="pointer-events-none absolute top-3.5 left-4 h-5 w-5 text-gray-400"
        />
        <input
          type="text"
          class="w-full h-12 pr-4 text-gray-800 placeholder-gray-400 bg-transparent border-0 pl-11 focus:ring-0 sm:text-sm"
          placeholder="Search..."
          name="query"
          id="query"
          value={if assigns[:query], do: @query, else: ""}
        />
      </div>
    </form>
    """
  end

  def carousel(assigns) do
    ~H"""
    <div
      id={"image-carousel-#{Ecto.UUID.generate}"}
      class="relative"
      phx-hook="Carousel"
      data-carousel-page={0}
      data-carousel-pages={Enum.count(@item.images)}
    >
      <!-- Carousel wrapper -->
      <div class="relative h-56 overflow-hidden rounded-lg carousel-body md:h-96">
        <div
          :for={{image, index} <- Enum.with_index(@item.images)}
          class="hidden duration-700 ease-in-out"
        >
          <img
            src={image}
            class="absolute block object-cover object-center w-full h-full -translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2"
            alt={"Image ##{index + 1} of #{@item.name}"}
          />
        </div>
      </div>
      <!-- Slider indicators -->
      <div class="absolute z-30 flex space-x-3 -translate-x-1/2 slide-indicators bottom-5 left-1/2 opacity-80">
        <div :for={_ <- @item.images} class="w-3 h-3 bg-white rounded-full opacity-30"></div>
      </div>
      <!-- Slider controls -->
      <div class="absolute top-0 left-0 z-30 h-full w-full flex">
        <button
          type="button"
          class="flex items-center justify-start px-5 h-full w-full cursor-pointer carousel-prev group focus:outline-none hover:bg-white/20"
        >
          <Heroicons.chevron_left class="w-5 h-5 text-white sm:w-6 sm:h-6 dark:text-gray-800" />
          <span class="sr-only">Previous</span>
        </button>
        <button
          type="button"
          class="flex items-center justify-end px-5 h-full w-full cursor-pointer carousel-next group focus:outline-none hover:bg-white/20"
        >
          <Heroicons.chevron_right class="w-5 h-5 text-white sm:w-6 sm:h-6 dark:text-gray-800" />
          <span class="sr-only">Next</span>
        </button>
      </div>
    </div>
    """
  end
end
