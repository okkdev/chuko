defmodule ChukoWeb.HomeLive do
  use ChukoWeb, :live_view
  import ChukoWeb.Components
  alias Chuko.SearchEngine

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <%!-- Scroll top button --%>
      <button
        id="scrolltop"
        phx-hook="ScrollTop"
        class="fixed bottom-0 right-0 z-50 hidden p-3 m-4 bg-white rounded-full shadow-lg ring-1 ring-black ring-opacity-5"
      >
        <Heroicons.chevron_up class="w-8 h-8 text-pink-300" />
      </button>
      <%!-- logo --%>
      <div class="drop-shadow-xl">
        <div
          style="filter:url('#goo');"
          class="py-8 text-center text-pink-300 font-gluten ani-tracking text-7xl"
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
      <%!-- Search bar --%>
      <div class="max-w-2xl mx-auto space-y-3">
        <.search_bar query={@query} phx-submit="search" disabled={@searching} />
      </div>
      <%!-- Product body --%>
      <div class="max-w-2xl px-4 py-8 mx-auto sm:py-12 sm:px-6 lg:max-w-7xl lg:px-8">
        <h2 class="sr-only">Products</h2>
        <%= cond do %>
          <% @searching -> %>
            <.loading />
          <% @query == "" && @items == [] -> %>
            <div class="py-16 text-center">
              try searching something :^)
            </div>
          <% @query != "" && @items == [] -> %>
            <div class="py-16 text-center">
              nothing found...
            </div>
          <% true -> %>
            <%!-- Filters/Sorting --%>
            <div class="flex justify-end mb-5">
              <form id="sorting" phx-change="sort" phx-update="ignore">
                <select
                  name="sorting"
                  phx-change="sort"
                  class="block py-3 pl-3 pr-10 text-base text-gray-700 transition-colors border-0 shadow-xl rounded-xl ring-1 ring-black ring-opacity-5 focus:border-pink-300 focus:outline-none focus:ring-pink-300 sm:text-sm"
                >
                  <option value="new" selected>↑ Newest first</option>
                  <option value="old">↓ Oldest first</option>
                  <option value="low">↑ Price lowest first</option>
                  <option value="high">↓ Price highest first</option>
                </select>
              </form>
            </div>
            <%!-- Actual product container --%>
            <%= if @sorting do %>
              <.loading />
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
        searching: false,
        sorting: false
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
        "load_more",
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
  def handle_event("load_more", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("sort", %{"sorting" => sort_type}, %{assigns: %{items: items}} = socket) do
    Task.async(fn ->
      items = List.flatten(items)

      items =
        case sort_type do
          "new" ->
            Enum.sort_by(items, & &1.created_at, {:desc, DateTime})

          "old" ->
            Enum.sort_by(items, & &1.created_at, {:asc, DateTime})

          "low" ->
            Enum.sort_by(items, & &1.price, :asc)

          "high" ->
            Enum.sort_by(items, & &1.price, :desc)
        end
        |> Enum.chunk_every(9)

      Phoenix.PubSub.broadcast!(
        Chuko.PubSub,
        "session_#{socket.id}",
        {:items_sorted, %{items: items}}
      )
    end)

    {:noreply, assign(socket, sorting: true)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, push_patch(socket, to: ~p"/search/#{query}")}
  end

  @impl true
  def handle_info({:items_sorted, %{items: items}}, socket) do
    socket =
      assign(socket,
        items: items,
        page_items: Enum.at(items, 0, []),
        page: 1,
        sorting: false
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:items_found, %{items: items}}, socket) do
    items =
      items
      |> Enum.sort_by(& &1.created_at, {:desc, DateTime})
      |> Enum.chunk_every(9)

    socket =
      assign(socket,
        items: items,
        page_items: Enum.at(items, 0, []),
        page: 1,
        pages: Enum.count(items),
        searching: false
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:search_failed, %{platform: platform}}, socket) do
    {:noreply, put_flash(socket, :error, "Searching #{platform} failed. Try again...")}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  defp search(query, socket) do
    Task.async(fn -> SearchEngine.search_platforms(query, "session_#{socket.id}") end)

    assign(socket, query: query, page_title: query, searching: true)
  end
end
