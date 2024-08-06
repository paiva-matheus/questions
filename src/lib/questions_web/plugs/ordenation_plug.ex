defmodule QuestionsWeb.Plugs.OrdenationPlug do
  @moduledoc "Parse *order_by* and *order* inputs from query string"
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_query_params(conn)
    order = conn.query_params["order"]
    order_by = conn.query_params["order_by"]
    assign(conn, :ordenation, order_by: order_by, order: order)
  end
end
