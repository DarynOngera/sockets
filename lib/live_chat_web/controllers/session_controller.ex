defmodule LiveChatWeb.SessionController do
  use LiveChatWeb, :controller

  alias LiveChat.Repo
  alias LiveChat.User
  alias Argon2

  def new(conn, _params) do
    form = Phoenix.Component.to_form(%{"email" => "", "password" => ""}, as: :session)
    render(conn, "new.html", form: form)
  end

  def create(conn, %{"session" => session_params} = params) do
    IO.inspect(params, label: "[Login POST] received params")
    process_login(conn, session_params)
  end

  # Also handle flat (unnested) params as a fallback, for debugging
  def create(conn, params) do
    IO.inspect(params, label: "[Login POST] fallback (unnested or bad param)")

    session_params =
      params["session"] || %{"email" => params["email"], "password" => params["password"]}

    process_login(conn, session_params)
  end

  defp process_login(conn, %{"email" => email, "password" => password} = session_params)
       when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Argon2.verify_pass(password, user.password_hash) ->
        conn
        |> LiveChat.Guardian.Plug.sign_in(user, %{})
        |> redirect(to: "/chat")

      true ->
        form = Phoenix.Component.to_form(session_params, as: :session)

        conn
        |> put_flash(:error, "Invalid email or password")
        |> render("new.html", form: form)
    end
  end

  # If params are missing or malformatted, render error
  defp process_login(conn, _bad) do
    conn
    |> put_flash(:error, "Malformed login submission. Please try again.")
    |> redirect(to: "/login")
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out(LiveChat.Guardian)
    |> redirect(to: "/")
  end
end
