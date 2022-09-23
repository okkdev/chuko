defmodule ChukoWeb.Components do
  use ChukoWeb, :component
  use PetalComponents

  def item(assigns) do
    ~H"""
    <div class="relative flex flex-col overflow-hidden bg-white border border-gray-200 rounded-lg group">
      <div class="bg-gray-200 aspect-w-3 aspect-h-4 group-hover:opacity-75 sm:aspect-none sm:h-96">
        <img
          src={Enum.at(@item.images, 0)}
          alt={@item.name}
          class="object-cover object-center w-full h-full sm:w-full sm:h-full"
        />
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

  def search_bar(assigns) do
    ~H"""
    <form
      class="w-full overflow-hidden transition-all transform bg-white divide-y divide-gray-100 shadow-2xl rounded-xl ring-1 ring-black ring-opacity-5"
      phx-submit="search"
    >
      <div class="relative">
        <Heroicons.Solid.search class="pointer-events-none absolute top-3.5 left-4 h-5 w-5 text-gray-400" />
        <input
          type="text"
          class="w-full h-12 pr-4 text-gray-800 placeholder-gray-400 bg-transparent border-0 pl-11 focus:ring-0 sm:text-sm"
          placeholder="Search..."
          name="query"
          id="query"
        />
      </div>
    </form>
    """
  end
end
