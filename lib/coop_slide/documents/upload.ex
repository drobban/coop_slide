defmodule CoopSlide.Documents.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do
    field :content_type, :string
    field :filename, :string
    field :path, :string
    field :hash, :string
    field :size, :integer

    timestamps()
  end

  def sha256(chunks_enum) do
    chunks_enum
    |> Enum.reduce(
      :crypto.hash_init(:sha256),
      &:crypto.hash_update(&2, &1)
    )
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  def upload_directory do
    Application.get_env(:coop_slide, :uploads_directory)
  end

  def upload_directory(slide_id) do
    [upload_directory(), "#{slide_id}"]
    |> Path.join()
  end

  def local_path(id, filename) do
    [upload_directory(), "#{id}-#{filename}"]
    |> Path.join()
  end

  def local_path(slide_id, id, filename) do
    [upload_directory(slide_id), "#{id}-#{filename}"]
    |> Path.join()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:path, :filename, :size, :content_type, :hash])
    |> validate_required([:path, :filename, :size, :content_type, :hash])

    # added validations
    # doesn't allow empty files
    |> validate_number(:size, greater_than: 0)
    |> validate_length(:hash, is: 64)
  end
end
