defmodule LiveChatWeb.Live.LiveChatLive do
  use Phoenix.LiveView
  import LiveChatWeb.CoreComponents

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(LiveChat.PubSub, "chat_room:lobby")

    {:ok,
     socket
     |> assign(form: Phoenix.Component.to_form(%{"message" => ""}, as: :message))
     |> assign(gif_form: Phoenix.Component.to_form(%{"query" => ""}, as: :gif_search))
     |> assign(gif_results: [])
     |> assign(gif_loading: false)
     |> assign(gif_error: nil)
     |> stream(:messages, [])}
  end

  def handle_event("new_message", %{"message" => %{"message" => content}}, socket) do
    now = NaiveDateTime.utc_now() |> Calendar.strftime("%H:%M:%S")

    message = %{
      id: System.unique_integer([:positive]),
      username: socket.assigns.current_user.username,
      content: content,
      inserted_at: now
    }

    Phoenix.PubSub.broadcast(LiveChat.PubSub, "chat_room:lobby", {:new_message, message})
    {:noreply, socket}
  end

  def handle_event("search_gifs", %{"gif_search" => %{"query" => query}}, socket) do
    api_key = System.get_env("GIPHY_API_KEY") || ""
    url = "https://api.giphy.com/v1/gifs/search"

    # Set loading state and clear error
    socket =
      socket
      |> assign(:gif_loading, true)
      |> assign(:gif_error, nil)
      |> assign(:gif_results, [])
      |> assign(:gif_form, Phoenix.Component.to_form(%{"query" => query}, as: :gif_search))

    req_result =
      Req.get(url,
        params: [
          api_key: api_key,
          q: query,
          limit: 12,
          rating: "g"
        ]
      )

    IO.inspect(req_result, label: "Giphy Req result for #{query}")

    case req_result do
      {:ok, %{body: %{"data" => data}}} when is_list(data) and data != [] ->
        gifs =
          Enum.map(data, fn gif ->
            {gif["id"], get_in(gif, ["images", "fixed_height", "url"])}
          end)

        IO.inspect(gifs, label: "Parsed GIFs for #{query}")
        {:noreply, assign(socket, gif_results: gifs, gif_loading: false, gif_error: nil)}

      {:ok, %{body: %{"data" => data}}} ->
        {:noreply,
         assign(socket,
           gif_results: [],
           gif_loading: false,
           gif_error: "No GIFs found for that search."
         )}

      _ ->
        {:noreply,
         assign(socket,
           gif_results: [],
           gif_loading: false,
           gif_error: "There was an error fetching GIFs. Please try again."
         )}
    end
  end

  def handle_event("send_gif", %{"url" => gif_url}, socket) do
    now = NaiveDateTime.utc_now() |> Calendar.strftime("%H:%M:%S")

    message = %{
      id: System.unique_integer([:positive]),
      username: socket.assigns.current_user.username,
      gif_url: gif_url,
      inserted_at: now
    }

    Phoenix.PubSub.broadcast(LiveChat.PubSub, "chat_room:lobby", {:new_message, message})
    {:noreply, socket}
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, stream(socket, :messages, [message])}
  end
end
