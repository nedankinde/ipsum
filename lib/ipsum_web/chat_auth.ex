defmodule IpsumWeb.ChatAuth do
  use IpsumWeb, :verified_routes

  alias Ipsum.Chats
  alias Ipsum.Chats.Chat

  def on_mount(:allowed_in_chat, %{"id" => chat_id}, session, socket) do
    user = Ipsum.Accounts.get_user_by_session_token(session["user_token"])

    case Chats.get_chat!(chat_id) do
      %Chat{} = chat ->
        if chat.user_1_id == user.id || chat.user_2_id == user.id do
          {:cont, socket}
        else
          {:halt,
           socket
           |> Phoenix.LiveView.redirect(to: ~p"/")}
        end

      _ ->
        {:halt,
         socket
         |> Phoenix.LiveView.redirect(to: ~p"/")}
    end
  end
end
