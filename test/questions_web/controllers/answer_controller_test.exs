defmodule QuestionsWeb.AnswerControllerTest do
  use QuestionsWeb.ConnCase, async: true

  alias Questions.Doubts.Question
  alias Questions.Factory
  alias Questions.Repo

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create/2" do
    test "returns 201 with created question", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")
      question = Factory.insert(:question, status: "open")

      params = %{
        "content" => "Answer for the question",
        "user_id" => user.id,
        "question_id" => question.id
      }

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.answer_path(conn, :create), params)

      response = json_response(conn, 201)["data"]

      assert response["content"] == params["content"]
      started_question = Repo.get(Question, question.id)
      assert started_question.status == "in_progress"
    end

    test "returns 403 when user doesn't have permission", %{conn: conn} do
      user = Factory.insert(:user, role: "student")

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.answer_path(conn, :create), %{})

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 401 for unauthorized request", %{conn: conn} do
      conn = post(conn, Routes.answer_path(conn, :create), %{})

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "detail" => "Unauthorized"
               }
             }
    end

    test "returns 422 when required fields are missing", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.answer_path(conn, :create), %{})

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "content" => ["can't be blank"],
                 "question_id" => ["can't be blank"],
                 "user_id" => ["can't be blank"]
               }
             }
    end
  end

  describe "delete/2" do
    test "returns 204", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")
      answer = Factory.insert(:answer)

      conn =
        conn
        |> authorize_request!(user)
        |> delete(Routes.answer_path(conn, :delete, answer.id))

      assert response(conn, 204) == ""
    end

    test "returns 404", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")

      conn =
        conn
        |> authorize_request!(user)
        |> delete(Routes.answer_path(conn, :delete, Ecto.UUID.generate()))

      assert json_response(conn, 404) == %{
               "errors" => %{
                 "detail" => "Not Found"
               }
             }
    end

    test "returns 403 when user doesn't have permission", %{conn: conn} do
      user = Factory.insert(:user, role: "student")
      answer = Factory.insert(:answer)

      conn =
        conn
        |> authorize_request!(user)
        |> delete(Routes.answer_path(conn, :delete, answer.id))

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 401 for unauthorized request", %{conn: conn} do
      answer = Factory.insert(:answer)
      conn = delete(conn, Routes.answer_path(conn, :delete, answer.id))

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "detail" => "Unauthorized"
               }
             }
    end
  end

  describe "favorite/2" do
    test "returns 200", %{conn: conn} do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question, user: user)
      answer = Factory.insert(:answer, question: question)

      conn =
        conn
        |> authorize_request!(user)
        |> patch(Routes.answer_answer_path(conn, :favorite, answer.id))

      response = json_response(conn, 200)["data"]
      assert response["favorite"] == true
    end

    test "returns 404", %{conn: conn} do
      user = Factory.insert(:user, role: "student")

      conn =
        conn
        |> authorize_request!(user)
        |> patch(Routes.answer_answer_path(conn, :favorite, Ecto.UUID.generate()))

      assert json_response(conn, 404) == %{
               "errors" => %{
                 "detail" => "Not Found"
               }
             }
    end

    test "returns 403 when user doesn't have permission", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")
      answer = Factory.insert(:answer)

      conn =
        conn
        |> authorize_request!(user)
        |> patch(Routes.answer_answer_path(conn, :favorite, answer.id))

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 401 for unauthorized request", %{conn: conn} do
      answer = Factory.insert(:answer)
      conn = patch(conn, Routes.answer_answer_path(conn, :favorite, answer.id))

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "detail" => "Unauthorized"
               }
             }
    end
  end

  describe "unfavorite/2" do
    test "returns 200", %{conn: conn} do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question, user: user)
      answer = Factory.insert(:answer, question: question, favorite: true)

      conn =
        conn
        |> authorize_request!(user)
        |> patch(Routes.answer_answer_path(conn, :unfavorite, answer.id))

      response = json_response(conn, 200)["data"]
      assert response["favorite"] == false
    end

    test "returns 404", %{conn: conn} do
      user = Factory.insert(:user, role: "student")

      conn =
        conn
        |> authorize_request!(user)
        |> patch(Routes.answer_answer_path(conn, :unfavorite, Ecto.UUID.generate()))

      assert json_response(conn, 404) == %{
               "errors" => %{
                 "detail" => "Not Found"
               }
             }
    end

    test "returns 403 when user doesn't have permission", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")
      answer = Factory.insert(:answer)

      conn =
        conn
        |> authorize_request!(user)
        |> patch(Routes.answer_answer_path(conn, :unfavorite, answer.id))

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 401 for unauthorized request", %{conn: conn} do
      answer = Factory.insert(:answer)
      conn = patch(conn, Routes.answer_answer_path(conn, :unfavorite, answer.id))

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "detail" => "Unauthorized"
               }
             }
    end
  end
end
