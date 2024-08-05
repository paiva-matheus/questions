defmodule QuestionsWeb.AnswerView do
  use QuestionsWeb, :view

  def render("show.json", %{answer: answer}) do
    %{data: render_one(answer, __MODULE__, "answer.json")}
  end

  def render("answer.json", %{answer: answer}) do
    %{
      id: answer.id,
      content: answer.content,
      monitor_id: answer.user_id,
      question_id: answer.question_id,
      favorite: answer.favorite
    }
  end

  def render("question_answer.json", %{answer: answer}) do
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
