defmodule Questions.Doubts.Thread do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Questions.Doubts.Question
  alias Questions.Doubts.Answer

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          question_id: Ecto.UUID.t(),
          question: nil | Question.t() | Ecto.Association.NotLoaded.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "threads" do
    belongs_to(:question, Question)
    has_many(:answers, Answer)

    timestamps()
  end

  @spec create_changeset(t(), map()) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = thread, %{} = attrs) do
    required_fields = ~w(question_id)a

    thread
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> foreign_key_constraint(:question_id)
  end
end
