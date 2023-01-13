defmodule CoopSlide.Repo.Migrations.AddPageRelation do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add :slide_id, references(:slides)
    end
  end
end
