defmodule QuestionsWeb.StudentsControllerTest do
  use QuestionsWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create/2" do
    test "returns 201 with created student", %{conn: conn} do
      attrs = %{
        name: "Dwight Schrute",
        email: "dwight@mail.com",
        password: Faker.String.base64(8)
      }

      conn = post(conn, Routes.student_path(conn, :create), attrs)

      assert %{
               "id" => _id,
               "name" => "Dwight Schrute",
               "email" => "dwight@mail.com",
               "role" => "student"
             } = json_response(conn, 201)["data"]
    end

    test "returns 422 when required fields are missing", %{conn: conn} do
      conn = post(conn, Routes.student_path(conn, :create), %{})

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "email" => ["can't be blank"],
                 "name" => ["can't be blank"],
                 "password" => ["can't be blank"]
               }
             }
    end
  end
end
