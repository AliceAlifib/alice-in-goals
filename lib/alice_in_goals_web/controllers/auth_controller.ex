defmodule AliceInGoalsWeb.AuthController do
  use AliceInGoalsWeb, :controller
  plug Ueberauth

  alias AliceInGoals.Accounts

  @doc """
  Initiates OAuth flow by redirecting to Google.
  """
  def request(conn, _params) do
    # Ueberauth handles the redirect
    name = user_info["name"] || user.name || "there"
    conn
  end

  @doc """
  Handles the OAuth callback from Google.
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_info = %{
      "sub" => auth.uid,
      "email" => auth.info.email,
      "name" => auth.info.name
    }

    case Accounts.find_or_create_from_google(user_info) do
      {:ok, user} ->
        name = user_info["name"] || user.name || "there"

        conn
        |> put_flash(:info, "Welcome, #{name}!")
        |> put_session(:user_id, user.id)
        |> redirect_after_login(user)

      {:error, _changeset} ->
        name = user_info["name"] || user.name || "there"

        conn
        |> put_flash(:error, "Failed to authenticate. Please try again.")
        |> redirect(to: "/")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    name = user_info["name"] || user.name || "there"

    conn
    |> put_flash(:error, "Failed to authenticate with Google.")
    |> redirect(to: "/")
  end

  @doc """
  Logs out the user.
  """
  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: "/")
  end

  # Private helpers

  defp redirect_after_login(conn, user) do
    cond do
      !user.onboarding_completed ->
        redirect(conn, to: ~p"/onboarding")

      true ->
        redirect(conn, to: ~p"/dashboard")
    end
  end
end
