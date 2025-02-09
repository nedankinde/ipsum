defmodule Ipsum.Accounts.UserFollow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "follow" do
    belongs_to :user_1, Ipsum.Accounts.User, type: :binary_id
    belongs_to :user_2, Ipsum.Accounts.User, type: :binary_id

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:user_1_id, :user_2_id])
    |> validate_required([:user_1_id, :user_2_id])
  end
end
