defmodule Questions.Question do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Questions.Accounts.User

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          title: String.t(),
          description: String.t(),
          category: String.t(),
          status: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          user_id: Ecto.UUID.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "questions" do
    field(:title, :string)
    field(:description, :string)
    field(:category, :string)
    field(:status, :string)
    belongs_to(:user, User)

    timestamps()
  end

  @spec create_changeset(t(), map()) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = question, %{} = attrs) do
    required_fields = ~w(title description category user_id)a

    question
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> foreign_key_constraint(:user_id)
    |> put_change(:status, "open")
    |> validate_inclusion(:category, ["technology", "engineering", "science", "others"])
  end

  # |> validate_inclusion(:status, ["open", "in_progress", "completed"])
end
