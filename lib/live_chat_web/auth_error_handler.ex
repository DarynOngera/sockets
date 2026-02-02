defmodule LiveChatWeb.AuthErrorHandler do
  import Plug.Conn

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> Plug.Conn.fetch_session()
    |> Phoenix.Controller.fetch_flash()
    |> Phoenix.Controller.put_flash(:error, "Authentication required")
    |> Phoenix.Controller.redirect(to: "/login")
    |> halt()
  end
end
