defmodule AppWeb.LiveAuthService do
  def get_user(socket, signed_token) do
    config = [otp_app: :my_app]
    conn = %Plug.Conn{secret_key_base: socket.endpoint.config(:secret_key_base)}
    store_config = [backend: Pow.Store.Backend.EtsCache]
    salt = Atom.to_string(Pow.Plug.Session)

    with {:ok, token} <- Pow.Plug.verify_token(conn, salt, signed_token, config),
         {user, _metadata} <- Pow.Store.CredentialsCache.get(store_config, token) do
      user
    else
      _any -> nil
    end
  end
end
