defmodule AliceInGoals.Repo.Migrations.AddBldgServerFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :resident_id, :string
      add :home_bldg_address, :string
      add :avatar, :string
    end

    create index(:users, [:resident_id])
    create index(:users, [:home_bldg_address])
  end
end
