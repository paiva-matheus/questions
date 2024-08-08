defmodule QuestionsWeb.AnswerController do
  use QuestionsWeb, :controller
  use QuestionsWeb.AnswersSwagger

  action_fallback QuestionsWeb.FallbackController

  alias Questions.AccessControl
  alias Questions.Doubts
  alias Questions.Doubts.{Answer, Question}

  def create(conn, params) do
    user = AccessControl.Guardian.Plug.current_resource(conn)

    with :ok <- AccessControl.authorize(user, :create_answer),
         {:ok, %Answer{} = answer} <-
           Doubts.create_answer(params),
         {:ok, %Question{} = question} <-
           Doubts.get_question_by_id(answer.question_id),
         {:ok, _} <-
           Doubts.start_question(question) do
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

  def favorite(conn, %{"answer_id" => answer_id}) do
    user = AccessControl.Guardian.Plug.current_resource(conn)

    with :ok <- AccessControl.authorize(user, :favorite_answer),
         {:ok, %Answer{} = answer} <-
           Doubts.get_answer_by_id(answer_id),
         {:ok, %Question{} = question} <-
           Doubts.get_question_by_id(answer.question_id),
         true = Doubts.question_belong_to_requesting_user?(question, user),
         {:ok, favorited_answer} <- Doubts.favorite_answer(answer) do
      conn
      |> put_status(:ok)
      |> render("show.json", answer: favorited_answer)
    end
  end

  def unfavorite(conn, %{"answer_id" => answer_id}) do
    user = AccessControl.Guardian.Plug.current_resource(conn)

    with :ok <- AccessControl.authorize(user, :unfavorite_answer),
         {:ok, %Answer{} = answer} <-
           Doubts.get_answer_by_id(answer_id),
         {:ok, %Question{} = question} <-
           Doubts.get_question_by_id(answer.question_id),
         true = Doubts.question_belong_to_requesting_user?(question, user),
         {:ok, unfavorited_answer} <- Doubts.unfavorite_answer(answer) do
      conn
      |> put_status(:ok)
      |> render("show.json", answer: unfavorited_answer)
    end
  end
end
