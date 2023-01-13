defmodule CoopSlide.Shows.Slide do
  use Ecto.Schema
  import Ecto.Changeset

  schema "slides" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(slide, attrs) do
    slide
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
