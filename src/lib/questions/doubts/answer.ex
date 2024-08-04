defmodule Questions.Doubts.Answer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Questions.Accounts.User
  alias Questions.Doubts.Question
  alias Questions.Repo

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
    field(:favorite, :boolean)

    timestamps()
  end

  @spec create_changeset(t(), map()) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = answer, %{} = attrs) do
    required_fields = ~w(content question_id user_id)a

    answer
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> foreign_key_constraint(:question_id)
    |> foreign_key_constraint(:user_id)
    |> validate_role()
  end

  @spec favorite_changeset(t()) :: Ecto.Changeset.t()
  def favorite_changeset(%__MODULE__{} = answer) do
    answer
    |> change(favorite: true)
    |> validate_favorite()
  end

  @spec unfavorite_changeset(t()) :: Ecto.Changeset.t()
  def unfavorite_changeset(%__MODULE__{} = answer) do
    answer
    |> change(favorite: false)
    |> validate_unfavorite()
  end

  defp validate_favorite(
         %Ecto.Changeset{
           data: %{
             question_id: question_id
           }
         } = changeset
       ) do
    case Repo.one(
           from a in __MODULE__, where: a.question_id == ^question_id and a.favorite == true
         ) do
      nil -> changeset
      _ -> add_error(changeset, :answer, "There is already a favorited answer for this question")
    end
  end

  defp validate_unfavorite(%Ecto.Changeset{data: %{favorite: false}} = changeset),
    do: add_error(changeset, :answer, "The answer is not favorited")

  defp validate_unfavorite(%Ecto.Changeset{} = changeset), do: changeset

  defp validate_role(
         %Ecto.Changeset{
           changes: %{
             user_id: user_id
           }
         } = changeset
       ) do
    case Repo.get(User, user_id) do
      %User{role: "student"} ->
        add_error(changeset, :user, "the user does not have permission to answer the question")

      _ ->
        changeset
    end
  end

  defp validate_role(%Ecto.Changeset{} = changeset), do: changeset
end
