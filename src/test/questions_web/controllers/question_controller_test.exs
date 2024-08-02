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
end
