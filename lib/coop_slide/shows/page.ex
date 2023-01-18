defmodule CoopSlide.Shows.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :content, :string
    field :memo, :string
    field :order, :integer
    belongs_to :slide, CoopSlide.Shows.Slide

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:content, :memo, :order, :slide_id])
    |> validate_required([:content, :order, :slide_id])
  end
end
