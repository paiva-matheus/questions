defmodule QuestionsWeb.QuestionSubscriberControllerTest do
  use QuestionsWeb.ConnCase, async: true

  alias Questions.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create/2" do
    test "returns 201 with created question subscriber", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")

      params = %{
        "category" => "technology",
        "user_id" => user.id
      }

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.question_subscriber_path(conn, :create), params)

      response = json_response(conn, 201)["data"]

      assert response["category"] == params["category"]

      assert response["user"] == %{
               "id" => response["user"]["id"],
               "name" => response["user"]["name"],
               "email" => response["user"]["email"],
               "role" => response["user"]["role"]
             }
    end

    test "returns 403 when user doesn't have permission", %{conn: conn} do
      user = Factory.insert(:user, role: "invalid")

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.question_subscriber_path(conn, :create), %{})

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 401 for unauthorized request", %{conn: conn} do
      conn = post(conn, Routes.question_subscriber_path(conn, :create), %{})

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
        |> post(Routes.question_subscriber_path(conn, :create), %{})

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "category" => ["can't be blank"],
                 "user_id" => ["can't be blank"]
               }
             }
    end
  end
end
