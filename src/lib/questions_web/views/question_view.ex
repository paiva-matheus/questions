defmodule QuestionsWeb.QuestionView do
  use QuestionsWeb, :view

  alias QuestionsWeb.AnswerView

  def render("show.json", %{question: question}) do
    %{data: render_one(question, __MODULE__, "question.json")}
  end

  def render("question.json", %{question: question}) do
    %{
      id: question.id,
      title: question.title,
      description: question.description,
      category: question.category,
      status: question.status,
      answers: render_nested_many(question.answers, AnswerView, "question_answer.json")
    }
  end
end
