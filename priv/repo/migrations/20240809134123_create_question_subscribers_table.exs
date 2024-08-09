defmodule Questions.Repo.Migrations.CreateQuestionSubscribersTable do
  use Ecto.Migration

  def change do
    create table(:question_subscribers, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :category, :string, null: false
      add(:user_id, references(:users, type: :uuid))

      timestamps()
    end
  end
end
