defmodule CoopSlide.Documents do
  import Ecto.Query, warn: false

  alias CoopSlide.Repo
  alias CoopSlide.Documents.Upload

  def create_upload_from_plug_upload(%Plug.Upload{
        filename: filename,
        path: tmp_path,
        content_type: content_type
      }) do
    hash =
      File.stream!(tmp_path, [], 2048)
      |> Upload.sha256()

    Repo.transaction(fn ->
      with {:ok, %File.Stat{size: size}} <- File.stat(tmp_path),
           {:ok, upload} <-
             %Upload{}
             |> Upload.changeset(%{
               filename: filename,
               content_type: content_type,
               hash: hash,
               size: size
             })
             |> Repo.insert(),
           :ok <-
             File.cp(
               tmp_path,
               Upload.local_path(upload.id, filename)
             ) do
        upload
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  def create_upload_from_plug_upload(slide_id, %Plug.Upload{
        filename: filename,
        path: tmp_path,
        content_type: content_type
      }) do
    hash =
      File.stream!(tmp_path, [], 2048)
      |> Upload.sha256()

    Repo.transaction(fn ->
      with {:ok, %File.Stat{size: size}} <- File.stat(tmp_path),
           {:ok, upload} <-
             %Upload{}
             |> Upload.changeset(%{
               filename: filename,
               content_type: content_type,
               hash: hash,
               size: size,
               path: slide_id
             })
             |> Repo.insert(),
           :ok <-
             File.cp(
               tmp_path,
               Upload.local_path(slide_id, upload.id, filename)
             ) do
        upload
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  def remove_upload(id) do
    upload =
      Upload
      |> Repo.get!(id)

    File.rm(Upload.local_path(upload.path, upload.id, upload.filename))
    Repo.delete(upload)
  end

  def list_uploads(slide_id) do
    Repo.all(from u in Upload, where: u.path == ^slide_id, order_by: [asc: u.size])
  end

  def get_upload!(id) do
    Upload
    |> Repo.get!(id)
  end
end
