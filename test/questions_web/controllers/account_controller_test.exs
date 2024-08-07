defmodule QuestionsWeb.AccountControllerTest do
  use QuestionsWeb.ConnCase, async: true

  alias Questions.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index/2" do
    test "list all accounts", %{conn: conn} do
      user1 = Factory.insert(:user, role: "admin")
      user2 = Factory.insert(:user, role: "student")
      user3 = Factory.insert(:user, role: "monitor")

      conn =
        conn
        |> authorize_request!(user1)
        |> get(Routes.account_path(conn, :index))

      expected_response =
        [
          %{
            "id" => user1.id,
            "email" => user1.email,
            "name" => user1.name,
            "role" => user1.role
          },
          %{
            "id" => user2.id,
            "email" => user2.email,
            "name" => user2.name,
            "role" => user2.role
          },
          %{
            "id" => user3.id,
            "email" => user3.email,
            "name" => user3.name,
            "role" => user3.role
          }
        ]
        |> sort_by_id()

      assert json_response(conn, 200)["data"] == expected_response
    end

    test "filter accounts by `q` param", %{conn: conn} do
      user_1 = Factory.insert(:user, %{name: "Jim Halpert", role: "admin"})
      user_2 = Factory.insert(:user, %{email: "jim@mail.com", role: "admin"})
      Factory.insert_list(3, :user)

      conn =
        conn
        |> authorize_request!(user_1)
        |> get(Routes.account_path(conn, :index, q: "jim"))

      expected_response = [
        %{
          "id" => user_1.id,
          "email" => user_1.email,
          "name" => user_1.name,
          "role" => user_1.role
        },
        %{
          "id" => user_2.id,
          "email" => user_2.email,
          "name" => user_2.name,
          "role" => user_2.role
        }
      ]

      assert json_response(conn, 200)["data"] == sort_by_id(expected_response)
    end

    test "forbids unauthorized users", %{conn: conn} do
      unauthorized_roles = ["student"]

      for role <- unauthorized_roles do
        user = Factory.insert(:user, role: role)
        conn = conn |> authorize_request!(user) |> get(Routes.account_path(conn, :index))
        assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
      end
    end
  end

  describe "create/2" do
    test "returns 201 with created monitor user", %{conn: conn} do
      user = Factory.insert(:user, role: "admin")

      attrs = %{
        name: "Thora Cummerata",
        email: "sunny1966@dach.name",
        password: Faker.String.base64(8),
        role: "monitor"
      }

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.account_path(conn, :create), attrs)

      assert %{
               "id" => _id,
               "name" => "Thora Cummerata",
               "email" => "sunny1966@dach.name",
               "role" => "monitor"
             } = json_response(conn, 201)["data"]
    end

    test "returns 201 with created student user", %{conn: conn} do
      user = Factory.insert(:user, role: "admin")

      attrs = %{
        name: "Thora Cummerata",
        email: "sunny1966@dach.name",
        password: Faker.String.base64(8),
        role: "student"
      }

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.account_path(conn, :create), attrs)

      assert %{
               "id" => _id,
               "name" => "Thora Cummerata",
               "email" => "sunny1966@dach.name",
               "role" => "student"
             } = json_response(conn, 201)["data"]
    end

    test "returns 201 with created admin user", %{conn: conn} do
      user = Factory.insert(:user, role: "admin")

      attrs = %{
        name: "Thora Cummerata",
        email: "sunny1966@dach.name",
        password: Faker.String.base64(8),
        role: "admin"
      }

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.account_path(conn, :create), attrs)

      assert %{
               "email" => "sunny1966@dach.name",
               "id" => _id,
               "name" => "Thora Cummerata",
               "role" => "admin"
             } = json_response(conn, 201)["data"]
    end

    test "returns 403 when user doesn't have permission", %{conn: conn} do
      user = Factory.insert(:user, role: "monitor")

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.account_path(conn, :create), %{})

      assert json_response(conn, 403) == %{
               "errors" => %{
                 "detail" => "Forbidden"
               }
             }
    end

    test "returns 401 for unauthorized request", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), %{})

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "detail" => "Unauthorized"
               }
             }
    end

    test "returns 422 when role is invalid", %{conn: conn} do
      user = Factory.insert(:user, role: "admin")

      attrs = %{
        name: "Thora Cummerata",
        email: "sunny1966@dach.name",
        password: Faker.String.base64(8),
        role: "invalid_role"
      }

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.account_path(conn, :create), attrs)

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "role" => ["is invalid"]
               }
             }
    end

    test "returns 422 when required fields are missing", %{conn: conn} do
      user = Factory.insert(:user, role: "admin")

      conn =
        conn
        |> authorize_request!(user)
        |> post(Routes.account_path(conn, :create), %{})

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "email" => ["can't be blank"],
                 "name" => ["can't be blank"],
                 "password" => ["can't be blank"],
                 "role" => ["can't be blank"]
               }
             }
    end
  end

  defp sort_by_id(enumerable) do
    Enum.sort(enumerable, fn a, b ->
      a = Map.get(a, :id) || Map.get(a, "id")
      b = Map.get(b, :id) || Map.get(b, "id")
      a >= b
    end)
  end
end
