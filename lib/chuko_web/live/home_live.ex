defmodule ChukoWeb.HomeLive do
  use ChukoWeb, :live_view
  import ChukoWeb.Components
  alias Chuko.SearchEngine

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <.search_bar query={@query} class="mb-3" phx-submit="search" />
      <div class="bg-white">
        <div class="max-w-2xl px-4 py-16 mx-auto sm:py-24 sm:px-6 lg:max-w-7xl lg:px-8">
          <h2 class="sr-only">Products</h2>
          <div class="grid grid-cols-1 gap-y-4 sm:grid-cols-2 sm:gap-x-6 sm:gap-y-10 lg:grid-cols-3 lg:gap-x-8">
            <%= for item <- @items do %>
              <.item item={item} />
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(query: "", items: [])

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"query" => query}, _url, socket) do
    {:noreply, search(query, socket)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, push_patch(socket, to: ~p"/search/#{query}")}
  end

  defp search(query, socket) do
    socket
    |> assign(query: query)
    |> assign(items: SearchEngine.search_platforms(query))
  end
end
