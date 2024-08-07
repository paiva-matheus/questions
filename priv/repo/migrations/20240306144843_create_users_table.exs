defmodule Questions.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :email, :string, null: false
      add :encrypted_password, :string
      add :name, :string, null: false
      add :role, :string, null: false
      add :token, :string

      timestamps()
    end

    create(unique_index(:users, [:token]))
    create(unique_index(:users, [:email]))
  end
end
