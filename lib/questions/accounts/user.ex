defmodule Questions.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          token: Ecto.UUID.t(),
          role: String.t(),
          name: String.t(),
          encrypted_password: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:role, :string)
    field(:name, :string)
    field(:token, :string)
    field(:email, :string)
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)

    timestamps()
  end

  def roles,
    do: [
      "admin",
      "monitor",
      "student"
    ]

  @spec create_changeset(t(), map()) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = user, %{} = attrs) do
    required_fields = ~w(role name email password)a

    user
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_inclusion(:role, roles())
    |> unique_constraint(:email)
    |> prepare_changes(&hash_password/1)
  end

  @spec update_password_changeset(t(), map()) :: Ecto.Changeset.t()
  def update_password_changeset(%__MODULE__{} = user, %{} = attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/[A-Z]+/,
      message: "password must contain an uppercase letter"
    )
    |> validate_format(:password, ~r/[0-9]+/, message: "password must contain a number")
    |> validate_confirmation(:password, required: true)
    |> prepare_changes(&hash_password/1)
  end

  @spec update_role_changeset(t(), map()) :: Ecto.Changeset.t()
  def update_role_changeset(%__MODULE__{} = user, %{} = attrs) do
    user
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> validate_inclusion(:role, roles())
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)
    hash = Bcrypt.hash_pwd_salt(password)

    changeset
    |> put_change(:encrypted_password, hash)
    |> delete_change(:password)
  end
end
