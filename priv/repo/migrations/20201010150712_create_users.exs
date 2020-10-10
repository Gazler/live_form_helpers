defmodule Demo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :active, :boolean, default: false, null: false
      add :birthday, :date
      add :age, :integer
      add :started_at, :naive_datetime
      add :bio, :text
      add :start_time, :time
      add :pet, :string

      timestamps()
    end

  end
end
