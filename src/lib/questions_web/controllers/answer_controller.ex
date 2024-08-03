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

  def delete(conn, %{"id" => answer_id}) do
    user = AccessControl.Guardian.Plug.current_resource(conn)

    with :ok <- AccessControl.authorize(user, :delete_answer),
         {:ok, %Answer{} = answer} <-
           Doubts.get_answer_by_id(answer_id),
         {:ok, %Answer{} = _} <-
           Doubts.delete_answer(answer) do
      send_resp(conn, :no_content, "")
    end
  end
end
