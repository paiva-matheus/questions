defmodule QuestionsWeb.QuestionControllerTest do
  use QuestionsWeb.ConnCase, async: true

  alias Questions.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create/2" do
    test "returns 201 with created question", %{conn: conn} do
      user = Factory.insert(:user)

      params = %{
        "title" => "First question",
        "description" => "I have a question",
        "category" => "technology",
        "user_id" => user.id
      }

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.question_path(conn, :create), params)

      response = json_response(conn, 201)["data"]

      assert response["title"] == params["title"]
      assert response["description"] == params["description"]
      assert response["category"] == params["category"]
      assert response["status"] == "open"
      assert response["answers"] == nil
    end

    test "returns 403 when user doesn't have permission", %{conn: conn} do
      user = Factory.insert(:user, role: "invalid")

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.question_path(conn, :create), %{})

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 401 for unauthorized request", %{conn: conn} do
      conn = post(conn, Routes.question_path(conn, :create), %{})

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "detail" => "Unauthorized"
               }
             }
    end

    test "returns 422 when required fields are missing", %{conn: conn} do
      user = Factory.insert(:user)

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.question_path(conn, :create), %{})

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "title" => ["can't be blank"],
                 "description" => ["can't be blank"],
                 "category" => ["can't be blank"],
                 "user_id" => ["can't be blank"]
               }
             }
    end
  end

  describe "show/2" do
    setup [:show_setup]

    defp show_setup(%{conn: conn}) do
      user = Factory.insert(:user)

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> authorize_request!(user)

      %{conn: conn}
    end

    test "returns 200", %{conn: conn} do
      question = Factory.insert(:question)
      answers = Factory.insert_list(10, :answer, question: question)
      conn = get(conn, Routes.question_path(conn, :show, question.id))

      assert json_response(conn, 200)["data"] == %{
               "id" => question.id,
               "title" => question.title,
               "description" => question.description,
               "category" => question.category,
               "status" => question.status,
               "answers" =>
                 Enum.map(answers, fn answer ->
                   %{
                     "id" => answer.id,
                     "content" => answer.content,
                     "monitor" => %{
                       "id" => answer.user.id,
                       "name" => answer.user.name,
                       "email" => answer.user.email
                     }
                   }
                 end)
             }
    end

    test "returns 404", %{conn: conn} do
      conn = get(conn, Routes.question_path(conn, :show, Ecto.UUID.generate()))
      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end

    test "returns 401", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "")
        |> get(Routes.question_path(conn, :show, Ecto.UUID.generate()))

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthorized"}}
    end
  end
end
