defmodule QuestionsWeb.OrdenationPlugTest do
  use QuestionsWeb.ConnCase, async: true
  use Plug.Test

  alias Plug.Conn
  alias QuestionsWeb.Plugs.OrdenationPlug

  describe "call/2" do
    test "assigns ordering", %{conn: conn} do
      conn =
        %Conn{conn | query_params: %{"order_by" => "email", "order" => "desc"}}
        |> OrdenationPlug.call([])

      assert [order_by: "email", order: "desc"] == conn.assigns[:ordenation]
    end

    test "assigns nil as default values", %{conn: conn} do
      conn = OrdenationPlug.call(conn, [])
      assert [order_by: nil, order: nil] == conn.assigns[:ordenation]
    end
  end
end
