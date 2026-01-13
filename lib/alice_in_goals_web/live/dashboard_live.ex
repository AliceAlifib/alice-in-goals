defmodule AliceInGoalsWeb.DashboardLive do
  use AliceInGoalsWeb, :live_view
  alias AliceInGoals.Accounts

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")

    if user_id do
      user = Accounts.get_user!(user_id)

      if !user.onboarding_completed do
        {:ok, push_navigate(socket, to: ~p"/onboarding")}
      else
        {:ok,
         socket
         |> assign(:user, user)
         |> assign(:page_title, "Your Office")}
      end
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  @impl true
  def handle_event("toggle_fullscreen", _params, socket) do
    {:noreply, push_event(socket, "toggle_fullscreen", %{})}
  end
end
