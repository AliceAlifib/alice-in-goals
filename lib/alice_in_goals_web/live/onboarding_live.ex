defmodule AliceInGoalsWeb.OnboardingLive do
  use AliceInGoalsWeb, :live_view
  alias AliceInGoals.Accounts

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")

    if user_id do
      user = Accounts.get_user!(user_id)

      if user.onboarding_completed do
        {:ok, push_navigate(socket, to: ~p"/dashboard")}
      else
        {:ok,
         socket
         |> assign(:user, user)
         |> assign(:current_step, 1)
         |> assign(:goals, user.goals || [""])
         |> assign(:tools, user.tools || %{})
         |> assign(:errors, %{})}
      end
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  @impl true
  def handle_event("add_goal", _params, socket) do
    goals = socket.assigns.goals ++ [""]
    {:noreply, assign(socket, :goals, goals)}
  end

  @impl true
  def handle_event("remove_goal", %{"index" => index}, socket) do
    index = String.to_integer(index)
    goals = List.delete_at(socket.assigns.goals, index)
    {:noreply, assign(socket, :goals, goals)}
  end

  @impl true
  def handle_event("update_goal", %{"index" => index, "value" => value}, socket) do
    index = String.to_integer(index)
    goals = List.replace_at(socket.assigns.goals, index, value)
    {:noreply, assign(socket, :goals, goals)}
  end

  @impl true
  def handle_event("update_tool", %{"category" => category, "value" => value}, socket) do
    tools = Map.put(socket.assigns.tools, category, value)
    {:noreply, assign(socket, :tools, tools)}
  end

  @impl true
  def handle_event("next_step", _params, socket) do
    case validate_current_step(socket) do
      :ok ->
        {:noreply, assign(socket, :current_step, socket.assigns.current_step + 1)}

      {:error, errors} ->
        {:noreply, assign(socket, :errors, errors)}
    end
  end

  @impl true
  def handle_event("prev_step", _params, socket) do
    {:noreply,
     socket
     |> assign(:current_step, socket.assigns.current_step - 1)
     |> assign(:errors, %{})}
  end

  @impl true
  def handle_event("edit_step", %{"step" => step}, socket) do
    step = String.to_integer(step)
    {:noreply, assign(socket, :current_step, step)}
  end

  @impl true
  def handle_event("complete_onboarding", _params, socket) do
    user = socket.assigns.user
    goals = Enum.reject(socket.assigns.goals, &(&1 == ""))
    tools = socket.assigns.tools

    # Update user with goals and tools
    {:ok, user} = Accounts.update_user(user, %{goals: goals, tools: tools})

    # Mark onboarding as complete
    {:ok, _user} = Accounts.mark_onboarding_complete(user)

    # TODO: Call BldgServerClient to create resident and provision
    # For now, just redirect to dashboard

    {:noreply,
     socket
     |> put_flash(:info, "Welcome to your office! Your space is ready.")
     |> push_navigate(to: ~p"/dashboard")}
  end

  # Private helpers

  defp validate_current_step(socket) do
    case socket.assigns.current_step do
      1 ->
        validate_goals(socket.assigns.goals)

      2 ->
        # Tools are optional, always valid
        :ok

      _ ->
        :ok
    end
  end

  defp validate_goals(goals) do
    non_empty_goals = Enum.reject(goals, &(&1 == "" || String.trim(&1) == ""))

    if length(non_empty_goals) > 0 do
      :ok
    else
      {:error, %{goals: "Please add at least one goal"}}
    end
  end

  defp step_title(1), do: "Build Your Foundation"
  defp step_title(2), do: "Lay the Groundwork"
  defp step_title(3), do: "Move Into Your Office"

  defp step_subtitle(1), do: "Define your life goals"
  defp step_subtitle(2), do: "Connect your tools (optional)"
  defp step_subtitle(3), do: "Review and complete setup"
end
