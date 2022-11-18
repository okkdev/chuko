defmodule ChukoWeb.HomeLive do
  use ChukoWeb, :live_view
  import ChukoWeb.Components
  alias Chuko.SearchEngine

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <div class="max-w-2xl mx-auto">
        <.search_bar query={@query} phx-submit="search" />
      </div>
      <div class="bg-white">
        <div class="max-w-2xl px-4 py-16 mx-auto sm:py-24 sm:px-6 lg:max-w-7xl lg:px-8">
          <h2 class="sr-only">Products</h2>
          <div
            id="infinite-scroll-body"
            phx-update={if @query_changed, do: "replace", else: "append"}
            class="grid grid-cols-1 gap-y-4 sm:grid-cols-2 sm:gap-x-6 sm:gap-y-10 lg:grid-cols-3 lg:gap-x-8"
          >
            <.item :for={item <- @page_items} item={item} />
          </div>
          <div id="infinite-scroll-marker" phx-hook="InfiniteScroll" data-page={@page}></div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        query: "",
        query_changed: false,
        items: [],
        page: 1,
        pages: 0
      )

    {:ok, socket, temporary_assigns: [page_items: []]}
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
  def handle_event(
        "load-more",
        _,
        %{assigns: %{items: items, page: page, pages: pages}} = socket
      )
      when page < pages do
    IO.inspect("page: #{page} pages: #{pages}", label: "load more")

    socket =
      assign(socket,
        items: items,
        query_changed: false,
        page_items: Enum.at(items, page, []),
        page: page + 1
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("load-more", _, socket) do
    IO.inspect("load no more")
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, push_patch(socket, to: ~p"/search/#{query}")}
  end

  defp search(query, socket) do
    items =
      SearchEngine.search_platforms(query)
      |> Enum.sort_by(& &1.created_at, {:desc, DateTime})
      |> Enum.chunk_every(9)

    assign(socket,
      query_changed: true,
      query: query,
      items: items,
      page_items: Enum.at(items, 0, []),
      pages: Enum.count(items)
    )
  end
end
