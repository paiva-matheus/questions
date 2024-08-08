defmodule QuestionsWeb.StudentView do
  use QuestionsWeb, :view

  alias QuestionsWeb.UserView

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end
end
