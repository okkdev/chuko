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
      <div class="flex justify-center py-10 sm:py-14">
        <svg
          class="h-12 fill-pink-300 drop-shadow-xl"
          width="719"
          height="134"
          viewBox="0 0 719 134"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path d="M49.8624 132.474C24.5424 128.567 6.75485 113.483 2.21722 91.9465C0.492918 83.7683 0.492918 71.41 2.30797 62.8683C7.02711 39.8783 21.366 25.7935 46.1415 19.7052C52.0405 18.2513 56.8503 17.7061 65.7441 17.7061C78.631 17.7061 82.5334 18.4331 91.1549 22.7948C99.0503 26.7022 102.227 30.0644 103.497 35.9709C104.949 42.3318 103.679 46.5117 98.9596 51.1461C95.511 54.5083 95.148 54.5991 83.3501 56.3257C69.7372 58.3248 64.5643 60.5965 62.5678 65.3217C61.2065 68.6839 61.9325 73.9544 64.1106 76.4078C67.6499 80.3152 70.6448 81.0422 85.8005 81.7691C97.6891 82.3144 101.047 82.7687 103.951 84.2226C110.848 87.7665 113.389 92.7644 113.389 102.851C113.389 116.936 104.586 126.204 86.6172 131.202C79.9923 133.02 58.3931 133.747 49.8624 132.474ZM342.041 132.474C312.637 130.021 292.49 116.118 284.323 92.5826C281.509 84.5861 280.874 69.2291 282.871 60.5057C286.773 43.7857 297.663 33.4265 312.819 31.9726C320.442 31.2457 329.064 33.4265 333.601 37.2431C336.959 40.06 338.684 44.4217 343.766 63.05C344.855 66.8665 346.307 69.4109 348.757 71.8644C352.478 75.6809 355.291 76.2261 359.647 73.9544C363.005 72.2278 365.093 68.5931 369.086 57.5978C370.901 52.6 373.805 46.6026 375.529 44.3309C383.425 33.4265 402.755 31.2457 412.919 40.1509C417.003 43.7857 421.722 53.6904 423.083 61.7778C425.443 75.8626 423.537 90.3109 417.729 102.124C413.827 110.03 411.286 113.119 403.935 119.117C390.866 129.748 368.087 134.655 342.041 132.474ZM634.856 130.293C618.611 127.658 607.63 122.479 598.101 113.028C587.936 102.942 584.397 92.9461 585.214 76.8622C585.849 66.3213 588.844 57.2344 594.743 48.6017C613.075 21.7952 655.91 13.0718 689.398 29.2465C702.739 35.7891 713.447 48.5109 717.077 62.1413C719.982 73.4091 718.53 88.0391 713.447 98.0348C706.369 112.029 689.761 124.023 670.794 129.021C661.355 131.475 645.292 132.02 634.856 130.293ZM146.488 127.749C132.966 123.206 126.341 98.2165 130.606 67.1391C132.422 53.6904 135.689 42.877 141.678 30.7913C150.118 13.8896 160.373 4.89349 174.712 1.71306C184.604 -0.467812 197.219 3.80306 201.212 10.6183C202.21 12.2539 203.935 17.6152 205.205 22.4313C208.745 36.607 209.743 37.4248 225.534 39.9691C243.594 42.877 253.032 48.7835 258.931 61.0509C263.015 69.32 264.467 76.2261 264.467 86.9487C264.467 106.304 258.296 118.844 245.862 124.569C242.142 126.295 239.873 126.659 233.157 126.568C219.726 126.477 216.277 123.751 208.926 107.94C203.299 95.8539 198.853 92.8552 193.317 97.217C191.955 98.3074 187.871 103.76 184.151 109.393C174.168 124.569 169.086 128.203 156.925 128.567C152.932 128.749 148.213 128.385 146.488 127.749ZM455.549 126.931C445.294 121.843 440.575 106.849 441.936 83.95C443.207 63.3226 449.831 33.8809 456.184 21.25C463.807 5.89306 475.424 -1.46738 487.857 0.986101C496.751 2.80349 500.471 8.98262 503.194 26.6113C505.917 44.0583 507.822 44.967 527.97 38.9696C545.666 33.6991 559.552 40.1509 558.644 53.1452C558.372 57.6887 557.464 59.7787 551.747 70.1378C548.389 76.1352 547.844 81.4965 550.113 85.7674C550.93 87.3122 554.197 91.6739 557.464 95.5813C564.997 104.577 566.267 108.121 563.908 114.937C560.731 124.205 552.019 129.567 541.31 128.749C533.959 128.113 528.968 125.477 518.35 116.481C509.819 109.121 506.189 107.122 501.742 107.122C497.386 107.122 494.573 109.03 486.768 117.572C482.412 122.479 478.146 126.204 475.878 127.204C470.614 129.657 460.722 129.567 455.549 126.931Z" />
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
              search something 🕵️
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
          <% :otherwise -> %>
            <%!-- Actual product container --%>
            <%= unless @sorting do %>
              <div
                id="infinite-scroll-body"
                phx-update="stream"
                class="grid grid-cols-1 gap-y-4 sm:grid-cols-2 sm:gap-x-6 sm:gap-y-10 lg:grid-cols-3 lg:gap-x-8"
              >
                <.item :for={{id, item} <- @streams.page_items} item={item} id={id} />
              </div>
              <div id="infinite-scroll-marker" phx-hook="InfiniteScroll" data-page={@page}></div>
            <% else %>
              <.loading />
            <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        query: "",
        items: [],
        page: 1,
        pages: 0,
        searching: false,
        sorting: false
      )
      |> stream(:page_items, [], dom_id: &"item-#{&1.id}")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Chuko.PubSub, "session_#{socket.id}")
    end

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
  def handle_event(
        "load_more",
        _,
        %{assigns: %{items: items, page: page, pages: pages}} = socket
      )
      when page < pages do
    socket =
      socket
      |> assign(
        items: items,
        page: page + 1
      )
      |> insert_page_items(Enum.at(items, page, []))

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
      socket
      |> assign(
        items: items,
        page: 1,
        sorting: false
      )
      |> insert_page_items(Enum.at(items, 0, []))

    {:noreply, socket}
  end

  @impl true
  def handle_info({:items_found, %{items: items}}, socket) do
    items =
      items
      |> Enum.sort_by(& &1.created_at, {:desc, DateTime})
      |> Enum.chunk_every(9)

    socket =
      socket
      |> assign(
        items: items,
        page_items: Enum.at(items, 0, []),
        page: 1,
        pages: Enum.count(items),
        searching: false
      )
      |> insert_page_items(Enum.at(items, 0, []))

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

  defp insert_page_items(socket, pages) do
    Enum.reduce(pages, socket, &stream_insert(&2, :page_items, &1))
  end
end
