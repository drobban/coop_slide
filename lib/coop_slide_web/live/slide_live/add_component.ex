defmodule CoopSlideWeb.SlideLive.AddComponent do
  use CoopSlideWeb, :live_component

  alias CoopSlide.Shows

  @impl true
  def update(%{page: page} = assigns, socket) do
    changeset = Shows.change_page(page, %{slide_id: assigns.slide.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"page" => page_params}, socket) do
    changeset =
      socket.assigns.page
      |> Shows.change_page(page_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"page" => page_params}, socket) do
    page_params =
      page_params
      |> Map.put("slide_id", socket.assigns.slide.id)

    save_page(socket, socket.assigns.action, page_params)
  end

  defp save_page(socket, :edit, page_params) do
    case Shows.update_page(socket.assigns.page, page_params) do
      {:ok, _page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_page(socket, :new, page_params) do
    case Shows.create_page(page_params) do
      {:ok, _page} ->
        {:noreply,
         socket
         |> put_flash(:info, "Page created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_page(socket, :add, page_params) do
    pages = Shows.get_slide_pages(socket.assigns.slide.id)

    order =
      case Enum.at(pages, -1) do
        nil ->
          1

        x ->
          x.order + 1
      end

    page_params =
      page_params
      |> Map.put("order", order)

    result =
      case Shows.create_page(page_params) do
        {:ok, page} ->
          {:noreply,
           socket
           |> push_redirect(
             to:
               CoopSlideWeb.Router.Helpers.slide_show_path(
                 CoopSlideWeb.Endpoint,
                 :edit_page,
                 page.slide_id,
                 page
               )
           )}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end

    result
  end

  defp save_page(socket, :edit_page, page_params) do
    case Shows.update_page(socket.assigns.page, page_params) do
      {:ok, _page} ->
        {:noreply,
         socket
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
