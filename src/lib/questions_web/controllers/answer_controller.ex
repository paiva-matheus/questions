defmodule QuestionsWeb.AnswerController do
  use QuestionsWeb, :controller

  action_fallback QuestionsWeb.FallbackController

  alias Questions.AccessControl
  alias Questions.Doubts
  alias Questions.Doubts.Answer

  def create(conn, params) do
    user = AccessControl.Guardian.Plug.current_resource(conn)

    with :ok <- AccessControl.authorize(user, :create_answer),
         {:ok, %Answer{} = answer} <-
           Doubts.create_answer(params) do
      conn
      |> put_status(:created)
      |> render("show.json", answer: answer)
    end
  end
end
