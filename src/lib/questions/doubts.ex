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
end
