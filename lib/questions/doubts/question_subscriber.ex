defmodule Questions.Doubts.QuestionSubscriber do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Questions.Accounts.User

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          category: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          user_id: Ecto.UUID.t(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "question_subscribers" do
    field(:category, :string)
    belongs_to(:user, User)

    timestamps()
  end

end
