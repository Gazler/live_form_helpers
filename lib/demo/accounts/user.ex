defmodule Demo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :active, :boolean, default: false
    field :age, :integer
    field :bio, :string
    field :birthday, :date
    field :name, :string
    field :pet, :string
    field :start_time, :time
    field :started_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :active, :birthday, :age, :started_at, :bio, :start_time, :pet])
    |> validate_required([:name, :active, :birthday, :age, :started_at, :bio, :start_time, :pet])
  end
end
