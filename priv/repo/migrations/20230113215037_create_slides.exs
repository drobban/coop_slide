defmodule CoopSlide.Repo.Migrations.CreateSlides do
  use Ecto.Migration

  def change do
    create table(:slides) do
      add :name, :string

      timestamps()
    end
  end
end
