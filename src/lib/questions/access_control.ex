defmodule Questions.AccessControl do
  @moduledoc "Use this module to check if a user is authorized to perform an action"
  alias Questions.Accounts.User

  @typedoc "Subjects that can perform actions"
  @type subject() :: User.t()

  @spec authorize(subject(), atom(), any()) :: :ok | :forbidden
  def authorize(subject, action, resource \\ nil) do
    if ok?(subject, action, resource), do: :ok, else: :forbidden
  end

  defp ok?(%User{} = user, :create_user, _resource),
    do: user.role == "admin"

  defp ok?(%User{} = user, :assign_role, _resource),
    do: user.role == "admin"

  defp ok?(%User{} = user, :list_users, _resource),
    do: user.role in ["admin", "monitor"]

  defp ok?(%User{} = user, :create_question, _resource),
    do: user.role in ["admin", "monitor", "student"]

  defp ok?(%User{} = user, :get_question, _resource),
    do: user.role in ["admin", "monitor", "student"]

  defp ok?(%User{} = user, :create_answer, _resource),
    do: user.role in ["admin", "monitor"]

  defp ok?(%User{} = user, :complete_question, _resource),
    do: user.role in ["admin", "student"]

  defp ok?(%User{} = user, :delete_answer, _resource),
    do: user.role in ["admin", "monitor"]
end
