defmodule QuestionsWeb.AuthorizationPlugTest do
  use QuestionsWeb.ConnCase, async: true
  use Plug.Test
  alias Plug.Conn
  alias Questions.Factory
  alias QuestionsWeb.AuthorizationPlug

  @opts []

  describe "init/1" do
    test "returns the opts" do
      assert @opts == AuthorizationPlug.init(@opts)
    end
  end

  describe "call/2" do
    test "assigns user to the conn", %{conn: conn} do
      user = Factory.insert(:user, token: Faker.UUID.v4())

      conn =
        conn
        |> Conn.put_req_header("authorization", "Bearer #{user.token}")
        |> AuthorizationPlug.call(@opts)

      assert user == conn.assigns[:current_user]
    end

    test "returns 401 for missing authorization header", %{conn: conn} do
      conn = AuthorizationPlug.call(conn, @opts)
      assert unauthorized_response?(conn)
    end

    test "returns 401 for invalid authorization header", %{conn: conn} do
      conn =
        conn
        |> Conn.put_req_header("authorization", "invalid-header")
        |> AuthorizationPlug.call(@opts)

      assert unauthorized_response?(conn)
    end

    test "returns 401 for invalid tokens", %{conn: conn} do
      conn =
        conn
        |> Conn.put_req_header("authorization", "Bearer invalid-token")
        |> AuthorizationPlug.call(@opts)

      assert unauthorized_response?(conn)
    end
  end

  defp unauthorized_response?(conn) do
    conn.halted and
      conn.status == 401 and
      conn.state == :sent and
      conn.resp_body == "{\"errors\":{\"detail\":\"Unauthorized\"}}"
  end
end
