defmodule QuestionsWeb.UserControllerTest do
  use QuestionsWeb.ConnCase, async: true

  alias Questions.AccessControl.Guardian
  alias Questions.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "sign_in/2" do
    test "returns 200 with a JWT token and user", %{conn: conn} do
      user = Factory.insert(:user)

      attrs = %{
        email: user.email,
        password: "12345678"
      }

      conn = post(conn, Routes.user_path(conn, :sign_in), attrs)

      assert %{
               "token" => token,
               "user" => %{
                 "name" => name,
                 "email" => email,
                 "role" => role
               }
             } = json_response(conn, 200)["data"]

      assert {:ok, _claims} = Guardian.decode_and_verify(token)
      assert name == user.name
      assert email == user.email
      assert role == user.role
    end

    test "returns 404 when email or password is invalid", %{conn: conn} do
      user = Factory.insert(:user)

      attrs = %{
        email: user.email,
        password: "1234567"
      }

      conn = post(conn, Routes.user_path(conn, :sign_in), attrs)

      assert json_response(conn, 404) == %{
               "errors" => %{"detail" => "Not Found"}
             }
    end

    test "returns 422 with error message", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :sign_in), %{})

      assert json_response(conn, 422)["errors"] == %{
               "email" => ["can't be blank"],
               "password" => ["can't be blank"]
             }
    end
  end
end
