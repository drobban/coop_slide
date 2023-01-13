defmodule CoopSlide.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :content, :string
      add :order, :integer

      timestamps()
    end
  end
end
