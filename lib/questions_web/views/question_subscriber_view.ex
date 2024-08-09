defmodule QuestionsWeb.QuestionSubscriberView do
  use QuestionsWeb, :view

  alias QuestionsWeb.UserView

  def render("show.json", %{question_subscriber: question_subscriber}) do
    %{data: render_one(question_subscriber, __MODULE__, "question_subscriber.json")}
  end

  def render("question_subscriber.json", %{question_subscriber: question_subscriber}) do
    %{
      id: question_subscriber.id,
      category: question_subscriber.category,
      user: render_nested_one(question_subscriber.user, UserView, "user.json")
    }
  end
end
