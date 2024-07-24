defmodule Questions.Repo.Migrations.CreateAnswersTable do
  use Ecto.Migration

  def change do
    create table(:answers, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :content, :string, null: false
      add(:thread_id, references(:threads, type: :uuid))

      timestamps()
    end
  end
end
