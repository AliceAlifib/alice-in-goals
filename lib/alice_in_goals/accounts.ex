defmodule AliceInGoals.Accounts do
  @moduledoc """
  The Accounts context for managing users.
  """

  import Ecto.Query, warn: false
  alias AliceInGoals.Repo
  alias AliceInGoals.Accounts.User
  alias AliceInGoals.BldgServerClient
  require Logger

  @doc """
  Finds or creates a user from Google OAuth data.
  """
  def find_or_create_from_google(%{
        "sub" => google_id,
        "email" => email,
        "name" => name
      }) do
    case Repo.get_by(User, google_id: google_id) do
      nil ->
        %User{}
        |> User.changeset(%{
          google_id: google_id,
          email: email,
          name: name,
          onboarding_completed: false
        })
        |> Repo.insert()
        |> case do
          {:ok, user} ->
            # Provision user on bldg-server
            case BldgServerClient.provision_user(user) do
              {:ok, %{resident_id: resident_id, home_bldg_address: home_bldg_address}} ->
                # Update user with bldg-server IDs
                user
                |> Ecto.Changeset.change(%{
                  resident_id: resident_id,
                  home_bldg_address: home_bldg_address
                })
                |> Repo.update()

              {:error, reason} ->
                # Log error but still return user
                Logger.error("Failed to provision user on bldg-server: #{inspect(reason)}")
                {:ok, user}
            end

          error ->
            error
        end

      user ->
        # Update name if it's missing
        if is_nil(user.name) or user.name == "" do
          user
          |> User.changeset(%{name: name})
          |> Repo.update()
        else
          {:ok, user}
        end
    end
  end

  @doc """
  Gets a single user by ID.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Marks a user's onboarding as complete.
  """
  def mark_onboarding_complete(user) do
    user
    |> User.changeset(%{onboarding_completed: true})
    |> Repo.update()
  end

  @doc """
  Updates a user's goals.
  """
  def update_goals(user, goals) when is_list(goals) do
    user
    |> User.changeset(%{goals: goals})
    |> Repo.update()
  end

  @doc """
  Updates a user's tools.
  """
  def update_tools(user, tools) when is_map(tools) do
    user
    |> User.changeset(%{tools: tools})
    |> Repo.update()
  end

  @doc """
  Updates a user with the given attributes.
  """
  def update_user(user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
end
