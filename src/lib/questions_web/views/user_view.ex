defmodule QuestionsWeb.UserView do
  use QuestionsWeb, :view

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role
    }
  end
end
