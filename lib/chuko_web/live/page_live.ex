defmodule ChukoWeb.PageLive do
  use ChukoWeb, :live_view
  alias ChukoWeb.Components.SearchInput

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container max-w-xl mx-auto flex items-center justify-center h-screen">
      <.live_component module={SearchInput} id={:search} />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_info({:search, query}, socket) do
    # {:noreply, push_redirect(socket, to: Routes.search_path(socket, :search, query))}
    {:noreply, socket}
  end
end
