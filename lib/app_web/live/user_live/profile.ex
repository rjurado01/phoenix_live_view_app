defmodule AppWeb.UserLive.Profile do
  use AppWeb, :live_view

  alias App.User
  alias AppWeb.LiveAuthService, as: Auth

  def render(assigns) do
    Phoenix.View.render(AppWeb.UserView, "profile.html", assigns)
  end

  def mount(_params, %{"app_auth" => token}, socket) do
    case Auth.get_user(socket, token) do
      nil -> {:ok, socket}
      user -> {:ok, assign(socket, :changeset, User.get(user.id) |> User.changeset_update(%{}))}
    end
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    IO.inspect user_params

    case User.update(socket.assigns.changeset, :changeset_update, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully.")
         |> assign(changeset: user |> User.changeset_update(%{}))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
