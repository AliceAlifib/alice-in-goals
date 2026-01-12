defmodule AliceInGoals.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :name, :string
      add :google_id, :string, null: false
      add :goals, {:array, :string}, default: []
      add :tools, :map, default: %{}
      add :onboarding_completed, :boolean, default: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:google_id])
  end
end
