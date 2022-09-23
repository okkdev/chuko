defmodule ChukoWeb.Components.SearchInput do
  use ChukoWeb, :live_component
  use PetalComponents

  def render(assigns) do
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
          value={if assigns[:query], do: @query, else: ""}
        />
      </div>
    </form>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
