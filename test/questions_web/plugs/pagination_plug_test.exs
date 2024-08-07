defmodule QuestionsWeb.PaginationPlugTest do
  use QuestionsWeb.ConnCase, async: true
  use Plug.Test

  alias Plug.Conn
  alias QuestionsWeb.Plugs.PaginationPlug

  @opts []

  describe "call/2" do
    test "assigns pagination", %{conn: conn} do
      conn =
        %Conn{conn | query_params: %{"page" => "2", "per_page" => "55"}}
        |> PaginationPlug.call(@opts)

      assert %{page: 2, per_page: 55} == conn.assigns[:pagination]
    end

    test "assigns default values for pagination", %{conn: conn} do
      conn = PaginationPlug.call(conn, @opts)
      assert %{page: 1, per_page: 10} == conn.assigns[:pagination]
    end

    test "returns bad request when page aren't a number", %{conn: conn} do
      conn =
        %Conn{conn | query_params: %{"page" => "abc"}}
        |> PaginationPlug.call(@opts)

      assert bad_request?(conn)
    end

    test "returns bad request when per_page aren't a number", %{conn: conn} do
      conn =
        %Conn{conn | query_params: %{"per_page" => "abc"}}
        |> PaginationPlug.call(@opts)

      assert bad_request?(conn)
    end
  end

  defp bad_request?(conn) do
    conn.halted and
      conn.status == 400 and
      conn.state == :sent and
      conn.resp_body == "{\"errors\":{\"detail\":\"Invalid pagination\"}}"
  end
end
