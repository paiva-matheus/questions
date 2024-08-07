defmodule Questions.Doubts.Question do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Questions.Accounts.User
  alias Questions.Doubts.Answer

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          title: String.t(),
          description: String.t(),
          category: String.t(),
          status: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          user_id: Ecto.UUID.t(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          answers: list(Answer.t())
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "questions" do
    field(:title, :string)
    field(:description, :string)
    field(:category, :string)
    field(:status, :string)
    belongs_to(:user, User)
    has_many(:answers, Answer)

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

  @spec complete_changeset(t()) :: Ecto.Changeset.t()
  def complete_changeset(%__MODULE__{status: "completed"} = question) do
    question
    |> change()
    |> add_error(:status, "question is already completed")
  end

  def complete_changeset(%__MODULE__{} = question) do
    question
    |> change(status: "completed")
  end

  @spec start_changeset(t()) :: Ecto.Changeset.t()
  def start_changeset(%__MODULE__{status: "open"} = question) do
    question
    |> change(status: "in_progress")
  end

  def start_changeset(%__MODULE__{} = question) do
    changeset = change(question)

    case question.status do
      "in_progress" -> add_error(changeset, :status, "question is already in progress")
      "completed" -> add_error(changeset, :status, "question is completed")
    end
  end
end
