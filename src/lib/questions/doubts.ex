defmodule Questions.Doubts do
  alias Questions.Accounts.User
  alias Questions.Doubts.Answer
  alias Questions.Doubts.Question
  alias Questions.Repo

  @spec create_question(map()) ::
          {:ok, Question.t()} | {:error, Ecto.Changeset.t()}
  def create_question(%{} = attrs) do
    %Question{}
    |> Question.create_changeset(attrs)
    |> Repo.insert()
  end

  @spec get_question_by_id(Ecto.UUID.t(), keyword()) ::
          {:ok, Question.t()} | {:error, :not_found}
  def get_question_by_id(question_id, preload_fields \\ []) do
    with {:uuid, {:ok, question_id}} <- {:uuid, Ecto.UUID.cast(question_id)},
         {:question, %Question{} = question} <-
           {:question, Repo.get(Question, question_id)} do
      {:ok, Repo.preload(question, preload_fields)}
    else
      {:uuid, :error} -> {:error, :not_found}
      {:question, nil} -> {:error, :not_found}
    end
  end

  @spec create_answer(map()) ::
          {:ok, Answer.t()} | {:error, Ecto.Changeset.t()}
  def create_answer(%{} = attrs) do
    %Answer{}
    |> Answer.create_changeset(attrs)
    |> Repo.insert()
  end

  @spec complete_question(Question.t(), User.t()) ::
          {:ok, Answer.t()} | {:error, Ecto.Changeset.t() | {:error, :forbidden}}
  def complete_question(%Question{} = question, %User{} = user) do
    case can_user_complete_question?(user, question) do
      true ->
        question
        |> Question.complete_changeset()
        |> Repo.update()

      false ->
        {:error, :forbidden}
    end
  end

  defp can_user_complete_question?(%User{role: "admin"}, _), do: true

  defp can_user_complete_question?(user, question) do
    if question.user_id == user.id do
      true
    else
      false
    end
  end

  @spec get_answer_by_id(Ecto.UUID.t(), keyword()) ::
          {:ok, Answer.t()} | {:error, :not_found}
  def get_answer_by_id(answer_id, preload_fields \\ []) do
    with {:uuid, {:ok, answer_id}} <- {:uuid, Ecto.UUID.cast(answer_id)},
         {:answer, %Answer{} = answer} <-
           {:answer, Repo.get(Answer, answer_id)} do
      {:ok, Repo.preload(answer, preload_fields)}
    else
      {:uuid, :error} -> {:error, :not_found}
      {:answer, nil} -> {:error, :not_found}
    end
  end

  @spec delete_answer(Answer.t()) ::
          {:ok, Answer.t()} | {:error, Ecto.Changeset}
  def delete_answer(%Answer{} = answer) do
    Repo.delete(answer)
  end
end
