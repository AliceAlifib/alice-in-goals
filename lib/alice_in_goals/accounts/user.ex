defmodule AliceInGoals.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :google_id, :string
    field :goals, {:array, :string}, default: []
    field :tools, :map, default: %{}
    field :onboarding_completed, :boolean, default: false

    field :resident_id, :string
    field :home_bldg_address, :string
    field :avatar, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :google_id, :goals, :tools, :onboarding_completed])
    |> validate_required([:email, :google_id])
    |> unique_constraint(:email)
    |> unique_constraint(:google_id)
  end
end
