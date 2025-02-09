defmodule Ipsum.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ipsum.Chats` context.
  """

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{
        user_id_1: "7488a646-e31f-11e4-aace-600308960662",
        user_id_2: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Ipsum.Chats.create_chat()

    chat
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        chat_id: "7488a646-e31f-11e4-aace-600308960662",
        content: "some content",
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Ipsum.Chats.create_message()

    message
  end
end
