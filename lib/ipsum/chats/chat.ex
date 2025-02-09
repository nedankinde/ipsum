defmodule Ipsum.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "chats" do
    belongs_to :user_1, Ipsum.Accounts.User, type: :binary_id
    belongs_to :user_2, Ipsum.Accounts.User, type: :binary_id
    has_many :messages, Ipsum.Chats.Message

    timestamps()
  end

  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:user_1_id, :user_2_id])
    |> validate_required([:user_1_id, :user_2_id])
    |> put_change(:id, Ecto.UUID.generate())
  end
end
