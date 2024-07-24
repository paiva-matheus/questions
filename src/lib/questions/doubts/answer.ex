defmodule Questions.Doubts.Answer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Questions.Doubts.Thread

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          content: String.t(),
          thread_id: Ecto.UUID.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "answers" do
    belongs_to(:thread, Thread)
    field(:content, :string)

    timestamps()
  end

  @spec create_changeset(t(), map()) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = thread, %{} = attrs) do
    required_fields = ~w(thread_id content)a

    thread
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> foreign_key_constraint(:thread_id)
  end
end
