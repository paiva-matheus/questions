defmodule Questions.Repo.Migrations.AddFavoriteFieldToAnswersTable do
  use Ecto.Migration

  def change do
    alter table(:answers) do
      add(:favorite, :boolean, default: false)
    end
  end
end
