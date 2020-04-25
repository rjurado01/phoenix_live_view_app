defmodule AppWeb.UserIndexLive do
  use Phoenix.LiveView

  alias App.QueryService, as: Query

  def render(assigns) do
    Phoenix.View.render(AppWeb.UserView, "index.html", assigns)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, init_params()) |> fetch}
  end

  defp fetch(socket) do
    with {:ok, users, meta} <- Query.run(App.User, socket.assigns) do
      assign(socket, users: users, meta: meta)
    else
      _ -> socket
    end
  end

  defp init_params do
    Query.init_params(%{
      order_field: "email",
      filter: %{"email" => "", "name" => ""}
    })
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

  def handle_event("sort",
    %{"field" => field},
    %{assigns: %{order_dir: order_dir, order_field: order_field}} = socket)
  when field == order_field do
    dir = if order_dir == "desc", do: "asc", else: "desc"
    {:noreply, assign(socket, %{order_field: field, order_dir: dir}) |> fetch}
  end

  def handle_event("sort", %{"field" => field}, socket) do
    {:noreply, assign(socket, %{order_field: field, order_dir: "desc"}) |> fetch}
  end

  def handle_event("filter", params, socket) do
    {:noreply, assign(socket, Map.merge(init_params(), %{filter: params})) |> fetch}
  end

  def handle_event("clear", _, socket) do
    {:noreply, assign(socket, init_params()) |> fetch}
  end

  def sort_order_icon(column, sort_by, "asc") when column == sort_by, do: "▲"
  def sort_order_icon(column, sort_by, "desc") when column == sort_by, do: "▼"
  def sort_order_icon(_, _, _), do: ""
end
