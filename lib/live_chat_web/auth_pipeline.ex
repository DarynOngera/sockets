defmodule LiveChatWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :live_chat,
    module: LiveChat.Guardian,
    error_handler: LiveChatWeb.AuthErrorHandler

  plug Guardian.Plug.VerifySession, claim: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource
end
