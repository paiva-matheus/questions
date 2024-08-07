defmodule QuestionsWeb.AuthorizationPlug do
  @moduledoc "Authorize requests based on Bearer token"
  import Plug.Conn
  alias Questions.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:token, {:ok, token}} <- {:token, get_authorization_token(conn)},
         {:user, {:ok, user}} <- {:user, get_user_by_token(token)} do
      assign(conn, :current_user, user)
    else
      {:token, {:error, :invalid_header}} -> respond_with_unauthorized(conn)
      {:user, {:error, :not_found}} -> respond_with_unauthorized(conn)
    end
  end

  defp get_authorization_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _invalid_header -> {:error, :invalid_header}
    end
  end

  defp get_user_by_token(token) do
    Accounts.get_user_by_token(token)
  end

  defp respond_with_unauthorized(conn) do
    body = Jason.encode!(%{errors: %{detail: "Unauthorized"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
    |> halt()
  end
end
