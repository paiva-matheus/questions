defmodule QuestionsWeb.QuestionController do
  use QuestionsWeb, :controller

  action_fallback QuestionsWeb.FallbackController

  alias Questions.AccessControl
  alias Questions.Doubts
  alias Questions.Doubts.Question

  def create(conn, params) do
    user = AccessControl.Guardian.Plug.current_resource(conn)

    with :ok <- AccessControl.authorize(user, :create_question),
         {:ok, %Question{} = question} <-
           Doubts.create_question(params) do
      conn
      |> put_status(:created)
      |> render("show.json", question: question)
    end
  end

  def show(conn, %{"id" => question_id}) do
    user = AccessControl.Guardian.Plug.current_resource(conn)
    preload_fields = [:user, answers: [:user]]

    with :ok <- AccessControl.authorize(user, :get_question),
         {:ok, %Question{} = question} <-
           Doubts.get_question_by_id(question_id, preload_fields) do
      conn
      |> put_status(:ok)
      |> render("show.json", question: question)
    end
  end
end
