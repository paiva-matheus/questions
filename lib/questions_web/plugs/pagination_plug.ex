defmodule QuestionsWeb.Plugs.PaginationPlug do
  @moduledoc "Parse *page* and *per_page* inputs from query string"
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_query_params(conn)

    with {:ok, page} <- to_integer(conn.query_params["page"] || "1"),
         {:ok, per_page} <- to_integer(conn.query_params["per_page"] || "10") do
      assign(conn, :pagination, %{page: page, per_page: per_page})
    else
      {:error, :bad_request} -> bad_request!(conn)
    end
  end

  defp bad_request!(conn) do
    body = Jason.encode!(%{errors: %{detail: "Invalid pagination"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, body)
    |> halt()
  end

  defp to_integer(value) do
    case Integer.parse(value) do
      {number, _} -> {:ok, number}
      :error -> {:error, :bad_request}
    end
  end
end
