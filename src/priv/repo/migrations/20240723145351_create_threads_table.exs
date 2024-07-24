defmodule Questions.Repo.Migrations.CreateThreadsTable do
  use Ecto.Migration

  def change do
    create table(:threads, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add(:question_id, references(:questions, type: :uuid))

      timestamps()
    end
  end
end
