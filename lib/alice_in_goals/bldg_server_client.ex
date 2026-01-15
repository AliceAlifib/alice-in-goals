defmodule AliceInGoals.BldgServerClient do
  @moduledoc """
  Client for interacting with the bldg-server API.
  Handles provisioning of users and their home buildings.
  """

  require Logger

  @base_url "https://bldg-server.fly.dev"

  @doc """
  Provisions a new user on the bldg-server by creating their home building and resident profile.
  Returns {:ok, %{resident_id: id, home_bldg_address: address}} on success.
  """
  def provision_user(user) do
    with {:ok, home_bldg} <- create_home_bldg(user),
         {:ok, resident} <- create_resident(user, home_bldg) do
      {:ok, %{resident_id: resident["id"], home_bldg_address: home_bldg["address"]}}
    else
      {:error, reason} ->
        Logger.error("Failed to provision user #{user.id} on bldg-server: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Creates a home building for the user on the bldg-server.
  """
  def create_home_bldg(user) do
    username = generate_username(user)

    payload = %{
      "entity" => %{
        "container_web_url" => "https://alicein.co",
        "entity_type" => "ground",
        "state" => "approved",
        "name" => username,
        "summary" => user.name || username
      }
    }
  end
end
