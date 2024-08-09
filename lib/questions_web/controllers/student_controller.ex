defmodule QuestionsWeb.StudentController do
  use QuestionsWeb, :controller
  use QuestionsWeb.StudentsSwagger

  action_fallback QuestionsWeb.FallbackController

  alias Questions.Accounts.User
  alias Questions.Students

  def create(conn, params) do
    with {:ok, %User{} = user} <- Students.register(params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end
end
