defmodule CoopSlide.Repo.Migrations.AddMemoToPage do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add :memo, :text
    end
  end
end
