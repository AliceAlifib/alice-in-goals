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
        "name" => username,
        "entity_type" => "ground",
        "flr" => "g",
        "flr_url" => "g",
        "state" => nil,
        "summary" => user.name || username,
        "web_url" => nil,
        "picture_url" => nil,
        "data" => "{\"flr_height\": \"1.08\", \"flr0_height\": \"0.01\"}",
        "owners" => [user.email],
        "bldg_url" => "g/#{username}",
        "is_composite" => true
      }
    }

    Logger.debug("BldgServer API Request - POST /v1/bldgs/build")
    Logger.debug("Payload: #{inspect(payload, pretty: true)}")

    case Req.post("#{@base_url}/v1/bldgs/build", json: payload) do
      {:ok, %{status: 200, body: body}} ->
        Logger.debug("BldgServer API Response - Success: #{inspect(body, pretty: true)}")
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "Failed to create home_bldg for user #{user.id}. Status: #{status}, Body: #{inspect(body)}"
        )

        {:error, "HTTP #{status}: #{inspect(body)}"}

      {:error, reason} ->
        Logger.error("HTTP request failed for user #{user.id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Creates a resident profile for the user on the bldg-server.
  """
  def create_resident(user, home_bldg) do
    username = generate_username(user)

    payload = %{
      "alias" => username,
      "direction" => "N",
      "email" => user.email,
      "flr" => home_bldg["flr"],
      "home_bldg" => home_bldg["address"],
      "location" => home_bldg["address"],
      "name" => user.name || username,
      "x" => 0,
      "y" => 0,
      "flr_url" => home_bldg["flr_url"],
      "nesting_depth" => 0
    }

    Logger.debug("BldgServer API Request - POST /v1/residents")
    Logger.debug("Payload: #{inspect(payload, pretty: true)}")

    case Req.post("#{@base_url}/v1/residents", json: payload) do
      {:ok, %{status: 200, body: body}} ->
        Logger.debug("BldgServer API Response - Success: #{inspect(body, pretty: true)}")
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "Failed to create resident for user #{user.id}. Status: #{status}, Body: #{inspect(body)}"
        )

        {:error, "HTTP #{status}: #{inspect(body)}"}

      {:error, reason} ->
        Logger.error("HTTP request failed for user #{user.id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Generates a URL-safe username from the user's email or name.
  """
  def generate_username(user) do
    base =
      cond do
        user.name && user.name != "" ->
          user.name

        user.email ->
          user.email
          |> String.split("@")
          |> List.first()

        true ->
          "user-#{user.id}"
      end

    base
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
