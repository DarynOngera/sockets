defmodule LiveChatWeb.UserController do
  use LiveChatWeb, :controller

  alias LiveChat.User
  alias LiveChat.Repo

  def new(conn, _params) do
    changeset = LiveChat.User.changeset(%LiveChat.User{}, %{})
    form = Phoenix.Component.to_form(changeset)
    render(conn, "new.html", form: form)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> LiveChat.Guardian.Plug.sign_in(user, %{})
        |> redirect(to: "/chat")

      {:error, changeset} ->
        form = Phoenix.Component.to_form(changeset)
        render(conn, "new.html", form: form)
    end
  end
end
