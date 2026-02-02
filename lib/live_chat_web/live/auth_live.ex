defmodule LiveChatWeb.Live.AuthLive do
  import Phoenix.LiveView
  import Phoenix.Component

  # On-mount hook for Guardian Auth in LiveView
  def on_mount(:default, _params, session, socket) do
    token = Map.get(session, "guardian_default_token")
    IO.inspect(token, label: "[AuthLive.on_mount] Guardian token")

    result = LiveChat.Guardian.resource_from_token(token)
    IO.inspect(result, label: "[AuthLive.on_mount] resource_from_token result")

    case result do
      {:ok, user, _claims} ->
        IO.inspect(user, label: "[AuthLive.on_mount] User from token")
        {:cont, assign(socket, :current_user, user)}

      _ ->
        IO.puts("[AuthLive.on_mount] Redirecting to login (auth failed!)")
        socket = redirect(socket, to: "/login")
        {:halt, socket}
    end
  end
end
