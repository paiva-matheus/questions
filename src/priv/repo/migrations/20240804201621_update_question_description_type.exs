defmodule Questions.Repo.Migrations.UpdateQuestionDescriptionType do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      modify :description, :text
    end
  end
end
