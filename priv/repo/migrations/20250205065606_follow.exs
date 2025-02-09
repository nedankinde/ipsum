defmodule Ipsum.Repo.Migrations.Follow do
  use Ecto.Migration

  def change do
    create table(:follow) do
      add :user_1_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :user_2_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:follow, [:user_1_id, :user_2_id])
  end
end
