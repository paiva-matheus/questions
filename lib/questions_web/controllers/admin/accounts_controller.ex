defmodule QuestionsWeb.AccountController do
  use QuestionsWeb, :controller

  action_fallback QuestionsWeb.FallbackController

  alias Questions.AccessControl
  alias Questions.Accounts
  alias QuestionsWeb.Extensions.Controllers.QueryParams

  def index(conn, _params) do
    user = AccessControl.Guardian.Plug.current_resource(conn)
    filters = QueryParams.cast(conn, ["q"])

    with :ok <- AccessControl.authorize(user, :list_users) do
      users = Accounts.list_users(filters)
      render(conn, "index.json", users: users)
    end
  end

  def create(conn, params) do
    user = AccessControl.Guardian.Plug.current_resource(conn)

    with :ok <- AccessControl.authorize(user, :create_user),
         {:ok, %{user: user}} <- Accounts.register(params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end
end
