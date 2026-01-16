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
         _ = Logger.info("Home building response structure: #{inspect(home_bldg)}")

    {:ok, resident} <-
      create_resident(user, home_bldg) do
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

    Logger.info("Creating home building for user #{user.id} with payload: #{inspect(payload)}")

    case Req.post("#{@base_url}/v1/bldgs/build", json: payload) do
      {:ok, %{status: 200, body: body}} ->
        Logger.info("Successfully created home building for user #{user.id}: #{inspect(body)}")
        {:ok, body}

      {:ok, %{status: 201, body: body}} ->
        Logger.info("Successfully created home building for user #{user.id}: #{inspect(body)}")
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "Failed to create home building for user #{user.id}. Status: #{status}, Body: #{inspect(body)}"
        )

        {:error, "BldgServer returned status #{status}: #{inspect(body)}"}

      {:error, reason} ->
        Logger.error("HTTP request failed for user #{user.id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Creates a resident profile for the user on the bldg-server.
  """
  def create_resident(user, home_bldg) do
    payload = %{
      "resident" => %{
        "email" => user.email,
        "name" => user.name || generate_username(user),
        "alias" => generate_username(user),
        "home_bldg" => home_bldg["data"]["address"]
      }
    }

    Logger.info("Creating resident for user #{user.id} with payload: #{inspect(payload)}")

    case Req.post("#{@base_url}/v1/residents", json: payload) do
      {:ok, %{status: 200, body: body}} ->
        Logger.info("Successfully created resident for user #{user.id}: #{inspect(body)}")
        {:ok, body}

      {:ok, %{status: 201, body: body}} ->
        Logger.info("Successfully created resident for user #{user.id}: #{inspect(body)}")
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "Failed to create resident for user #{user.id}. Status: #{status}, Body: #{inspect(body)}"
        )

        {:error, "BldgServer returned status #{status}: #{inspect(body)}"}

      {:error, reason} ->
        Logger.error("HTTP request failed for user #{user.id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Helper function to generate a username
  defp generate_username(user) do
    cond do
      user.name ->
        user.name
        |> String.downcase()
        |> String.replace(~r/[^a-z0-9]+/, "-")
        |> String.trim("-")

      true ->
        user.email
        |> String.split("@")
        |> List.first()
        |> String.downcase()
        |> String.replace(~r/[^a-z0-9]+/, "-")
        |> String.trim("-")
    end
  end
end
