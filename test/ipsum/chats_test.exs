defmodule Ipsum.ChatsTest do
  use Ipsum.DataCase

  alias Ipsum.Chats

  describe "chats" do
    alias Ipsum.Chats.Chat

    import Ipsum.ChatsFixtures

    @invalid_attrs %{user_id_1: nil, user_id_2: nil}

    test "list_chats/0 returns all chats" do
      chat = chat_fixture()
      assert Chats.list_chats() == [chat]
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = chat_fixture()
      assert Chats.get_chat!(chat.id) == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      valid_attrs = %{user_id_1: "7488a646-e31f-11e4-aace-600308960662", user_id_2: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Chat{} = chat} = Chats.create_chat(valid_attrs)
      assert chat.user_id_1 == "7488a646-e31f-11e4-aace-600308960662"
      assert chat.user_id_2 == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()
      update_attrs = %{user_id_1: "7488a646-e31f-11e4-aace-600308960668", user_id_2: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, update_attrs)
      assert chat.user_id_1 == "7488a646-e31f-11e4-aace-600308960668"
      assert chat.user_id_2 == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_chat/2 with invalid data returns error changeset" do
      chat = chat_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat(chat, @invalid_attrs)
      assert chat == Chats.get_chat!(chat.id)
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end
  end

  describe "messages" do
    alias Ipsum.Chats.Message

    import Ipsum.ChatsFixtures

    @invalid_attrs %{content: nil, user_id: nil, chat_id: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chats.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chats.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{content: "some content", user_id: "7488a646-e31f-11e4-aace-600308960662", chat_id: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Message{} = message} = Chats.create_message(valid_attrs)
      assert message.content == "some content"
      assert message.user_id == "7488a646-e31f-11e4-aace-600308960662"
      assert message.chat_id == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{content: "some updated content", user_id: "7488a646-e31f-11e4-aace-600308960668", chat_id: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Message{} = message} = Chats.update_message(message, update_attrs)
      assert message.content == "some updated content"
      assert message.user_id == "7488a646-e31f-11e4-aace-600308960668"
      assert message.chat_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_message(message, @invalid_attrs)
      assert message == Chats.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chats.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chats.change_message(message)
    end
  end
end
