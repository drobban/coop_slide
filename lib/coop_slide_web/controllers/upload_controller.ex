defmodule CoopSlideWeb.UploadController do
  use CoopSlideWeb, :controller

  alias CoopSlide.Documents

  def new(conn, _params) do
    render(conn, "new.html")
  end

  # def index(conn, _params) do
  #   uploads = Documents.list_uploads()
  #   render(conn, "index.html", uploads: uploads)
  # end

  def create(conn, %{"upload" => %Plug.Upload{} = upload}) do
    case Documents.create_upload_from_plug_upload(upload) do
      {:ok, upload} ->
        put_flash(conn, :info, "file uploaded correctly")
        redirect(conn, to: Routes.upload_path(conn, :index))

      {:error, reason} ->
        put_flash(conn, :error, "error upload file: #{inspect(reason)}")
        render(conn, "new.html")
    end
  end

  def create(conn, %{"files" => data}) do
    results =
      Enum.reduce(data, [], fn {_k, upload}, acc ->
        [Documents.create_upload_from_plug_upload(upload) | acc]
      end)

    IO.inspect(results)

    json(conn, %{data: []})
  end

  def show(conn, %{"id" => id}) do
    upload = Documents.get_upload!(id)
    local_path = Documents.Upload.local_path(upload.id, upload.filename)
    send_download(conn, {:file, local_path}, filename: upload.filename)
  end

  def index(conn, %{"action" => "files"} = args) do
    data = Documents.list_uploads()

    files =
      Enum.reduce(data, [], fn upload, acc -> [%{"file" => Integer.to_string(upload.id),
                                                 "thumb" => Integer.to_string(upload.id),
                                                 "type" => upload.content_type,
                                                 "changed" => "07/07/2017 3:06 PM",
                                                 "size" => "53.50kB"

                                                } | acc ] end)

    data =
      %{"success" => true,
        "time" => "2017-07-10 17:10:26",
        "data" => %{
          "sources" => [%{
                           "name" => "public",
                           "baseurl" => "/uploads",
                           "path" => "/",
                           "files" => files,
                           "folders" => []
                        },
                       ]
        },
        "code" => 220
       }

    json(conn, data)
  end

  def index(conn, %{"action" => "permissions"}) do
    # To be implemented. but this whole module and routes needs
    # to be refactored.
    data =
      %{"success" => true,
        "code" => 220
       }

    json(conn, data)
  end

  def index(conn, %{"action" => "fileRemove", "name" => id}) do
    IO.inspect("something else")
    Documents.remove_upload(id)
    data =
      %{"success" => true,
        "code" => 220
       }

    json(conn, data)
  end

end
