defmodule AppWeb.UserIndexLive do
  use Phoenix.LiveView

  alias App.QueryService, as: Query
  alias AppWeb.Router.Helpers, as: Routes

  def render(assigns) do
    Phoenix.View.render(AppWeb.UserView, "index.html", assigns)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, Query.init_params) |> fetch}
  end

  def fetch(socket) do
    with {:ok, users, meta} <- Query.run(App.User, socket.assigns) do
      assign(socket, users: users, meta: meta)
    else
      _ -> socket
    end
  end

  def handle_event("prev-page", _, %{assigns: %{page_number: current}} = socket) do
    {:noreply, assign(socket, %{page_number: current - 1}) |> fetch}
  end

  def handle_event("next-page", _, %{assigns: %{page_number: current}} = socket) do
    {:noreply, assign(socket, %{page_number: current + 1}) |> fetch}
  end

  def handle_event("change-page-size", %{"page_size" => page_size}, socket) do
    {:noreply, assign(socket, %{page_size: String.to_integer(page_size)}) |> fetch}
  end
end
