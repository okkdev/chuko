defmodule ChukoWeb.Components.SearchInput do
  use ChukoWeb, :live_component
  use PetalComponents
  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <form
      class="transform w-full divide-y divide-gray-100 overflow-hidden rounded-xl bg-white shadow-2xl ring-1 ring-black ring-opacity-5 transition-all"
      id={@myself}
      phx-hook="LocalstorageHook"
      phx-submit="search"
      phx-target={@myself}
    >
      <div class="relative">
        <Heroicons.Solid.search class="pointer-events-none absolute top-3.5 left-4 h-5 w-5 text-gray-400" />
        <input
          type="text"
          class="h-12 w-full border-0 bg-transparent pl-11 pr-4 text-gray-800 placeholder-gray-400 focus:ring-0 sm:text-sm"
          placeholder="Search..."
          name="query"
          id="query"
          phx-focus={JS.show(transition: "fade-in", to: "#history")}
          phx-blur={JS.hide(transition: "fade-out", to: "#history")}
        />
      </div>

      <%= if not Enum.empty?(@history) do %>
        <ul
          class="max-h-72 scroll-py-2 overflow-y-auto py-2 text-sm text-gray-800 hidden"
          id="history"
          role="listbox"
        >
          <%= for term <- @history do %>
            <li class="cursor-pointer select-none px-4 py-2" role="option" tabindex="-1">
              <%= term %>
            </li>
          <% end %>
        </ul>
      <% end %>
    </form>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, history: [])}
  end

  def handle_event("receive_history", %{"history" => nil}, socket) do
    {:noreply, push_event(socket, "set_history", %{history: Jason.encode!([])})}
  end

  def handle_event("receive_history", %{"history" => history}, socket) do
    {:noreply, assign(socket, history: Jason.decode!(history))}
  end

  def handle_event("search", %{"query" => query}, socket) do
    # send(self(), {:search, query})

    new_history = [query | socket.assigns.history]

    socket
    |> assign(history: new_history)
    |> push_event("set_history", %{history: Jason.encode!(new_history)})

    {:noreply, socket}
  end
end
