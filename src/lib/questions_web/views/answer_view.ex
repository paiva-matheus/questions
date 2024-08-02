defmodule QuestionsWeb.AnswerView do
  use QuestionsWeb, :view

  def render("answer.json", %{answer: answer}) do
    %{
      id: answer.id,
      content: answer.content,
      monitor: %{
        id: answer.user.id,
        name: answer.user.name,
        email: answer.user.email
      }
    }
  end
end
