defmodule LiveChat.Guardian do
  use Guardian, otp_app: :live_chat

  alias LiveChat.Repo
  alias LiveChat.User

  # Encodes a User into the JWT subject
  def subject_for_token(%User{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, :reason_for_error}

  # Decodes the JWT subject back into a User resource
  def resource_from_claims(%{"sub" => id}) do
    case Repo.get(User, id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_), do: {:error, :reason_for_error}
end
