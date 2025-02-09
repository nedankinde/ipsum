defmodule Ipsum.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "posts" do
    field :body, :string
    belongs_to :user, Ipsum.Accounts.User, foreign_key: :user_id, type: :binary_id
    has_many :comments, Ipsum.Posts.Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :user_id])
    |> validate_required([:body, :user_id])
    |> maybe_generate_uuid(attrs)
  end

  defp maybe_generate_uuid(changeset, attrs) do
    if changeset.data.id == nil do
      put_change(changeset, :id, Ecto.UUID.generate())
    else
      changeset
    end
  end
end
