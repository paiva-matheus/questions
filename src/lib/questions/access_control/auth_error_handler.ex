defmodule Questions.AccessControl.AuthErrorHandler do
  @moduledoc "handles authentication errors"
  import Plug.Conn

  def auth_error(conn, {_type, _reason}, _opts) do
    body = Jason.encode!(%{errors: %{detail: "Unauthorized"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
    |> halt()
  end
end
