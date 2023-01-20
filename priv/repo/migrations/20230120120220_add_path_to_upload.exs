defmodule CoopSlide.Repo.Migrations.AddPathToUpload do
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      add :path, :string
    end
  end
end
