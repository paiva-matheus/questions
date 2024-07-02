defmodule Questions.Accounts do
  @moduledoc "Use this module to register users, make logins, etc."

  import Ecto.Query

  alias Questions.AccessControl.Guardian
  alias Questions.Accounts
  alias Questions.Accounts.User
  alias Questions.Repo

  @spec get_user(Ecto.UUID.t()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user(user_id) do
    with {:uuid, {:ok, user_id}} <- {:uuid, Ecto.UUID.cast(user_id)},
         {:user, %User{} = user} <-
           {:user, Repo.get(User, user_id)} do
      {:ok, user}
    else
      {:uuid, :error} -> {:error, :not_found}
      {:user, nil} -> {:error, :not_found}
    end
  end

  def register(%{} = attrs) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, %User{} = user} -> {:ok, %{user: user}}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @spec get_active_user_by_email_and_password(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, :not_found}
  def get_active_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    with {:user, %User{} = user} <- {:user, Repo.get_by(User, email: email)},
         {:password, true} <- {:password, Bcrypt.verify_pass(password, user.encrypted_password)} do
      {:ok, user}
    else
      {:user, nil} -> {:error, :not_found}
      {:password, false} -> {:error, :not_found}
    end
  end

  @spec sign_in(Map.t()) ::
          {:ok, Guardian.Token.token(), Guardian.Token.claims()} | {:error, any()}
  def sign_in(%{} = attrs) do
    schema = %{email: :string, password: :string}

    changeset =
      {%{}, schema}
      |> Ecto.Changeset.cast(attrs, Map.keys(schema))
      |> Ecto.Changeset.validate_required(Map.keys(schema))

    with {:ok, data} <- Ecto.Changeset.apply_action(changeset, :sign_in),
         {:ok, user} <- Accounts.get_active_user_by_email_and_password(data.email, data.password) do
      Guardian.encode_and_sign(user, %{}, ttl: {1, :week})
    end
  end

  @spec get_user_by_token(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user_by_token(token) do
    case Repo.get_by(User, token: token) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  @spec list_users(keyword()) :: list(User.t())
  def list_users(filters) do
    query =
      from u in User,
        as: :u,
        order_by: [desc: u.id]

    query
    |> filter_by_name_or_email(filters)
    |> Repo.all()
  end

  defp filter_by_name_or_email(%Ecto.Query{} = q, filters) do
    case Keyword.fetch(filters, :q) do
      {:ok, query} ->
        name_or_email = "%#{query}%"

        from [u: u] in q, where: ilike(u.name, ^name_or_email) or ilike(u.email, ^name_or_email)

      :error ->
        q
    end
  end
end
