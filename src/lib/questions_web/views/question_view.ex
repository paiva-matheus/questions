defmodule QuestionsWeb.QuestionView do
  use QuestionsWeb, :view

  alias QuestionsWeb.AnswerView
  alias QuestionsWeb.UserView

  def render("index.json", %{questions: questions, pagination: pagination}) do
    %{
      pagination: pagination,
      data: render_many(questions, __MODULE__, "question.json")
    }
  end

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
      answers: render_nested_many(question.answers, AnswerView, "question_answer.json"),
      user: render_nested_one(question.user, UserView, "user.json")
    }
  end
end
