defmodule QuestionsWeb.QuestionSubscriberController do
  use QuestionsWeb, :controller
  use QuestionsWeb.QuestionSubscribersSwagger

  action_fallback QuestionsWeb.FallbackController

  alias Questions.AccessControl
  alias Questions.Subscribers
  alias Questions.Doubts.QuestionSubscriber

  def create(conn, params) do
    user = AccessControl.Guardian.Plug.current_resource(conn)

    with :ok <- AccessControl.authorize(user, :create_question_subscriber),
         {:ok, %QuestionSubscriber{} = question_subscriber} <-
           Subscribers.create_question_subscriber(params) do
      conn
      |> put_status(:created)
      |> render("show.json", question_subscriber: question_subscriber)
    end
  end
end
