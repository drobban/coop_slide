defmodule CoopSlide.Repo.Migrations.ChangeContentType do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      modify :content, :text
    end
  end
end
