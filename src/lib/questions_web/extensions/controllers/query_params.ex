defmodule QuestionsWeb.Extensions.Controllers.QueryParams do
  @moduledoc false

  alias Plug.Conn
  alias Plug.Conn.Unfetched

  @spec cast(Conn.t(), list(String.t())) :: keyword() | no_return()
  def cast(%Conn{query_params: %Unfetched{}}, _filters) do
    raise "Unfetched query params"
  end

  def cast(%Conn{query_params: query_params}, filters) do
    filters
    |> Enum.filter(&Map.has_key?(query_params, &1))
    |> Enum.map(&{String.to_atom(&1), query_params[&1]})
  end
end
