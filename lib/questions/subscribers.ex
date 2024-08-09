defmodule Questions.Subscribers do
  @moduledoc false

  alias Questions.Doubts.QuestionSubscriber
  alias Questions.Repo

  @spec create_question_subscriber(map()) ::
          {:ok, QuestionSubscriber.t()} | {:error, Ecto.Changeset.t()}
  def create_question_subscriber(%{} = attrs) do
    %QuestionSubscriber{}
    |> QuestionSubscriber.create_changeset(attrs)
    |> Repo.insert()
  end
end
