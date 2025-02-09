defmodule Ipsum.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :content, :string
    belongs_to :user, Ipsum.Accounts.User, type: :binary_id
    belongs_to :chat, Ipsum.Chats.Chat, type: :binary_id

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :user_id, :chat_id])
    |> validate_required([:content, :user_id, :chat_id])
  end
end
