defmodule QuestionsWeb.UserController do
  use QuestionsWeb, :controller
  use QuestionsWeb.UsersSwagger

  action_fallback QuestionsWeb.FallbackController

  alias Questions.AccessControl.Guardian
  alias Questions.Accounts

  def sign_in(conn, params) do
    with {:ok, jwt, claims} <- Accounts.sign_in(params),
         {:ok, user} <- Guardian.resource_from_claims(claims) do
      json(conn, %{
        data: %{token: jwt, user: %{name: user.name, email: user.email, role: user.role}}
      })
    end
  end
end
