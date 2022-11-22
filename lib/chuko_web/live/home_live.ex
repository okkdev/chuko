defmodule ChukoWeb.HomeLive do
  use ChukoWeb, :live_view
  import ChukoWeb.Components
  alias Chuko.SearchEngine

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <div class="drop-shadow-xl">
        <div
          style="filter:url('#goo');"
          class="font-gluten ani-tracking text-7xl text-pink-300  text-center py-8"
        >
          chuko
        </div>
        <%!-- gooey text trick --%>
        <svg class="hidden" xmlns="http://www.w3.org/2000/svg" version="1.1">
          <defs>
            <filter id="goo">
              <feGaussianBlur in="SourceGraphic" stdDeviation="4" result="blur" />
              <feColorMatrix
                in="blur"
                mode="matrix"
                values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 18 -7"
                result="goo"
              />
              <feBlend in="SourceGraphic" in2="goo" />
            </filter>
          </defs>
        </svg>
      </div>
      <div class="max-w-2xl mx-auto">
        <.search_bar query={@query} phx-submit="search" disabled={@loading} />
      </div>
      <div class="max-w-2xl px-4 py-13 mx-auto sm:py-24 sm:px-6 lg:max-w-7xl lg:px-8">
        <h2 class="sr-only">Products</h2>
        <%= if @loading do %>
          <div class="flex items-center justify-center">
            <Heroicons.arrow_path class="text-gray-400 w-20 h-20 animate-spin" />
          </div>
        <% else %>
          <div
            id="infinite-scroll-body"
            phx-update="append"
            class="grid grid-cols-1 gap-y-4 sm:grid-cols-2 sm:gap-x-6 sm:gap-y-10 lg:grid-cols-3 lg:gap-x-8"
          >
            <.item :for={item <- @page_items} item={item} />
          </div>
          <div id="infinite-scroll-marker" phx-hook="InfiniteScroll" data-page={@page}></div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        query: "",
        items: [],
        page: 1,
        pages: 0,
        loading: false
      )

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Chuko.PubSub, "session_#{socket.id}")
    end

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
    socket =
      assign(socket,
        items: items,
        page_items: Enum.at(items, page, []),
        page: page + 1
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("load-more", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, push_patch(socket, to: ~p"/search/#{query}")}
  end

  @impl true
  def handle_info({:items_ready, %{items: items}}, socket) do
    items =
      items
      |> Enum.sort_by(& &1.created_at, {:desc, DateTime})
      |> Enum.chunk_every(9)

    socket =
      assign(socket,
        items: items,
        page_items: Enum.at(items, 0, []),
        pages: Enum.count(items),
        loading: false
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  defp search(query, socket) do
    Task.async(fn -> SearchEngine.search_platforms(query, "session_#{socket.id}") end)

    assign(socket, query: query, page_title: query, loading: true)
  end
end
