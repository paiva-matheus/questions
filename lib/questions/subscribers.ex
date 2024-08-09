defmodule Questions.Subscribers do
  @moduledoc false

  alias Questions.Doubts.QuestionSubscriber
  alias Questions.Repo

  @spec create_question_subscriber(map()) ::
          {:ok, QuestionSubscriber.t()} | {:error, Ecto.Changeset.t()}
  def create_question_subscriber(%{} = attrs) do
    preload_fields = [[:user]]

    result =
      %QuestionSubscriber{}
      |> QuestionSubscriber.create_changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, %QuestionSubscriber{} = created_question_subscriber} ->
        {:ok, Repo.preload(created_question_subscriber, preload_fields)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
