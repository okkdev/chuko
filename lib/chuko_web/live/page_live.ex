defmodule ChukoWeb.PageLive do
  use ChukoWeb, :live_view
  alias ChukoWeb.Components.SearchInput

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container flex items-center justify-center h-screen max-w-xl mx-auto">
      <.live_component module={SearchInput} id={:search} />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, push_redirect(socket, to: Routes.search_path(socket, :search, query))}
  end
end
