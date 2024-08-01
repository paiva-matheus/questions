defmodule Questions.Doubts do
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
end
