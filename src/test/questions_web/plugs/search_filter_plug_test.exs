defmodule QuestionsWeb.SearchFilterPlugTest do
  use QuestionsWeb.ConnCase, async: true
  use Plug.Test

  alias Plug.Conn
  alias QuestionsWeb.Plugs.SearchFilterPlug

  describe "init/1" do
    test "initialize with filters" do
      assert [] == SearchFilterPlug.init()

      filters = [:email, :name]
      assert filters == SearchFilterPlug.init(filters)
    end
  end

  describe "call/2" do
    test "assigns search_filters", %{conn: conn} do
      # missing keys
      conn =
        %Conn{conn | query_params: %{"email" => "email@bol.com"}}
        |> SearchFilterPlug.call([:name, :email])

      assert [email: "email@bol.com"] == conn.assigns[:search_filters]

      # extra keys
      conn =
        %Conn{
          conn
          | query_params: %{"email" => "email@bol.com", "name" => "test", "other-key" => "xxx"}
        }
        |> SearchFilterPlug.call([:name, :email])

      assert [name: "test", email: "email@bol.com"] == conn.assigns[:search_filters]

      # no query string
      conn = SearchFilterPlug.call(%Conn{conn | query_params: %{}}, [:name, :email])
      assert [] == conn.assigns[:search_filters]
    end
  end
end
