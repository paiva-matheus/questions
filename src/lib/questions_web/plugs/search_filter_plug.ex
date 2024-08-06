defmodule QuestionsWeb.Plugs.SearchFilterPlug do
  @moduledoc "Parse allowed inputs from query string"
  import Plug.Conn

  def init(filters \\ []), do: filters

  def call(conn, filters) do
    conn = fetch_query_params(conn)

    search_filters =
      filters
      |> Enum.map(&{&1, conn.query_params[to_string(&1)]})
      |> Enum.reject(fn {_, val} -> is_nil(val) end)

    assign(conn, :search_filters, search_filters)
  end
end
