defmodule Questions.Repo.Migrations.CreateAnswersTable do
  use Ecto.Migration

  def change do
    create table(:answers, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :content, :string, null: false
      add(:question_id, references(:questions, type: :uuid))
      add(:user_id, references(:users, type: :uuid))

      timestamps()
    end
  end
end
