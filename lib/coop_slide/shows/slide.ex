defmodule CoopSlide.Shows.Slide do
  use Ecto.Schema
  import Ecto.Changeset

  schema "slides" do
    field :name, :string
    has_many :pages, CoopSlide.Shows.Page, foreign_key: :slide_id
    timestamps()
  end

  @doc false
  def changeset(slide, attrs) do
    slide
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
