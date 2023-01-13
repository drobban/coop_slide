defmodule CoopSlide.Shows.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :content, :string
    field :order, :integer
    belongs_to :slide, EctoAssoc.Slide

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:content, :order, :slide])
    |> validate_required([:content, :order, :slide])
  end
end
