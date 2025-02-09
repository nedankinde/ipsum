defmodule Ipsum.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_1_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :user_2_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:chats, [:user_1_id, :user_2_id])
  end
end
