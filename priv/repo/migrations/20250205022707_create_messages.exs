defmodule Ipsum.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :chat_id, references(:chats, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
