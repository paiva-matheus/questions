defmodule Questions.Students do
  @moduledoc false

  alias Questions.Accounts.User
  alias Questions.Repo

  @spec register(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register(%{} = attrs) do
    attrs = Map.put(attrs, get_role_key(attrs), "student")

    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, %User{} = user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp get_role_key(attrs), do: if(Map.has_key?(attrs, :name), do: :role, else: "role")
end
