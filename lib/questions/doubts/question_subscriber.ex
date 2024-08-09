defmodule Questions.Doubts.QuestionSubscriber do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Questions.Accounts.User
  alias Questions.Repo

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          category: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          user_id: Ecto.UUID.t(),
          user: User.t() | Ecto.Association.NotLoaded.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "question_subscribers" do
    field(:category, :string)
    belongs_to(:user, User)

    timestamps()
  end

  @spec create_changeset(t(), map()) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = question_subscriber, %{} = attrs) do
    required_fields = ~w(category user_id)a

    question_subscriber
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> foreign_key_constraint(:user_id)
    |> validate_inclusion(:category, ["technology", "engineering", "science", "others"])
    |> validate_user()
  end

  defp validate_user(
         %Ecto.Changeset{
           changes: %{
             user_id: user_id
           }
         } = changeset
       ) do
    case Repo.get(User, user_id) do
      %User{role: "monitor"} -> changeset
      nil -> add_error(changeset, :user_id, "does not exist")
      _ -> add_error(changeset, :user, "Only users with the monitor role can subscriber question")
    end
  end

  defp validate_user(%Ecto.Changeset{} = changeset), do: changeset
end
