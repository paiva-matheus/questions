defmodule Questions.Repo.Migrations.CreateQuestionsTable do
  use Ecto.Migration

  def change do
    create table(:questions, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :title, :string, null: false
      add :description, :string, null: false
      add :category, :string, null: false
      add :status, :string
      add(:user_id, references(:users, type: :uuid))

      timestamps()
    end
  end
end
