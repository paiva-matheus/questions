defmodule Questions.Doubts.Answer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Questions.Accounts.User
  alias Questions.Doubts.Question

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          content: String.t(),
          question_id: Ecto.UUID.t(),
          question: Question.t() | Ecto.Association.NotLoaded.t(),
          user_id: Ecto.UUID.t(),
          user: User.t() | Ecto.Association.NotLoaded.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "answers" do
    belongs_to(:question, Question)
    belongs_to(:user, User)
    field(:content, :string)

    timestamps()
  end

  @spec create_changeset(t(), map()) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = thread, %{} = attrs) do
    required_fields = ~w(content question_id user_id)a

    thread
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> foreign_key_constraint(:question_id)
    |> foreign_key_constraint(:user_id)
  end
end
