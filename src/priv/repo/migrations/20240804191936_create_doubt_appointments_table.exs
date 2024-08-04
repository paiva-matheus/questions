defmodule Questions.Repo.Migrations.CreateDoubtAppointmentsTable do
  use Ecto.Migration

  def change do
    create table(:doubt_appointments, primary_key: false) do
      add(:id, :uuid, null: false, primary_key: true)
      add(:question_id, references(:questions, type: :uuid, on_delete: :nothing), null: false)
      add(:user_id, references(:users, type: :uuid, on_delete: :nothing))
      add(:datetime, :utc_datetime_usec, null: false)
      add(:platform, :string, null: false)

      timestamps(type: :naive_datetime_usec)
    end
  end
end
