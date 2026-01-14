defmodule AliceInGoals.BldgServerClient do
  @moduledoc """
  Client for interacting with the bldg-server API.
  Handles provisioning residents and their home buildings.
  """

  require Logger

  @base_url "https://bldg-server.fly.dev"

  @doc """
  Provisions a new user on the bldg-server by:
  1. Creating their home building
  2. Creating their resident record

  Returns `{:ok, %{resident_id: ..., home_bldg_address: ...}}` on success.
  Returns `{:error, reason}` on failure.
  """
  def provision_user(user) do
    with {:ok, home_bldg_response} <- create_home_bldg(user),
         home_bldg_address <- Map.get(home_bldg_response, "address"),
         {:ok, resident_response} <- create_resident(user, home_bldg_address) do
      {:ok,
       %{
         resident_id: Map.get(resident_response, "id"),
         home_bldg_address: home_bldg_address,
         home_bldg_response: home_bldg_response,
         resident_response: resident_response
       }}
    else
      {:error, reason} = error ->
        Logger.error("Failed to provision user #{user.id} on bldg-server: #{inspect(reason)}")
        error
    end
  end

  @doc """
  Creates a home building for the user on bldg-server.

  POST /v1/bldgs/build
  """
  def create_home_bldg(user) do
    username = generate_username(user)

    payload = %{
      "container_web_url" => "https://alice-in-goals.app",
      "web_url" => "https://alice-in-goals.app/#{username}",
      "name" => username,
      "entity_type" => "ground",
      "state" => "approved",
      "summary" => user.name || user.email,
      "picture_url" => user.avatar || ""
    }

    Logger.debug("BldgServer create_home_bldg payload: #{inspect(payload, pretty: true)}")
    Logger.info("Creating home_bldg for user #{user.id} with username: #{username}")

    case Req.post("#{@base_url}/v1/bldgs/build", json: payload) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        Logger.info("Successfully created home_bldg for user #{user.id}: #{inspect(body)}")
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "Failed to create home_bldg for user #{user.id}. Status: #{status}, Body: #{inspect(body)}"
        )

        {:error, "HTTP #{status}: #{inspect(body)}"}

      {:error, exception} ->
        Logger.error(
          "Network error creating home_bldg for user #{user.id}: #{inspect(exception)}"
        )

        {:error, exception}
    end
  end

  @doc """
  Creates a resident record for the user on bldg-server.

  POST /v1/residents
  """
  def create_resident(user, home_bldg_address) do
    username = generate_username(user)

    payload = %{
      "alias" => username,
      "direction" => 0,
      "email" => user.email,
      "flr" => "#{home_bldg_address}/l0",
      "home_bldg" => home_bldg_address,
      "location" => "g/#{username}/l0/b(0,0)",
      "name" => user.name || user.email,
      "x" => 0,
      "y" => 0,
      "flr_url" => "g/#{username}/l0",
      "nesting_depth" => 1
    }

    Logger.debug("BldgServer create_resident payload: #{inspect(payload, pretty: true)}")
    Logger.info("Creating resident for user #{user.id} in home_bldg: #{home_bldg_address}")

    case Req.post("#{@base_url}/v1/residents", json: payload) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        Logger.info("Successfully created resident for user #{user.id}: #{inspect(body)}")
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "Failed to create resident for user #{user.id}. Status: #{status}, Body: #{inspect(body)}"
        )

        {:error, "HTTP #{status}: #{inspect(body)}"}

      {:error, exception} ->
        Logger.error("Network error creating resident for user #{user.id}: #{inspect(exception)}")
        {:error, exception}
    end
  end

  @doc """
  Generates a URL-safe username from the user's email or name.
  """
  def generate_username(user) do
    # Try to use name first, fall back to email
    base =
      cond do
        user.name && String.trim(user.name) != "" ->
          user.name

        true ->
          # Extract username from email (before @)
          user.email
          |> String.split("@")
          |> List.first()
      end

    # Convert to lowercase, replace spaces/special chars with hyphens
    base
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
