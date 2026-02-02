defmodule LiveChatWeb.LiveChatChannel do
  use LiveChatWeb, :channel

  @impl true
  def join("live_chat:" <> _room_id, _payload, socket) do
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("new_message", %{"content" => content}, socket) do
    broadcast(socket, "new_message", %{
      "username" => socket.assigns.current_user.username,
      "content" => content
    })

    {:noreply, socket}
  end
end
