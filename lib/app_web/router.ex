defmodule AppWeb.Router do
  use AppWeb, :router
  use Pow.Phoenix.Router
  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowEmailConfirmation, PowInvitation]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug AppWeb.EnsureRolePlug, :admin
    # plug :put_layout, {AppWeb.LayoutView, :admin}
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

  scope "/" do
    pipe_through :browser

    pow_session_routes()
    pow_extension_routes()
  end

  scope "/", PowInvitation.Phoenix, as: "pow_invitation" do
    pipe_through [:browser, :protected, :admin]

    resources "/invitations", InvitationController, only: [:new, :create, :show]
  end

  scope "/", AppWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/admin", AppWeb do
    pipe_through [:browser, :protected]

    resources "/users", UserController, only: [:index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end
end
