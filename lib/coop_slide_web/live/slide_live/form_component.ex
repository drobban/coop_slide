defmodule CoopSlideWeb.SlideLive.FormComponent do
  use CoopSlideWeb, :live_component

  alias CoopSlide.Shows

  @impl true
  def update(%{slide: slide} = assigns, socket) do
    changeset = Shows.change_slide(slide)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"slide" => slide_params}, socket) do
    changeset =
      socket.assigns.slide
      |> Shows.change_slide(slide_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"slide" => slide_params}, socket) do
    save_slide(socket, socket.assigns.action, slide_params)
  end

  defp save_slide(socket, :edit, slide_params) do
    case Shows.update_slide(socket.assigns.slide, slide_params) do
      {:ok, _slide} ->
        {:noreply,
         socket
         |> put_flash(:info, "Slide updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_slide(socket, :new, slide_params) do
    case Shows.create_slide(slide_params) do
      {:ok, _slide} ->
        {:noreply,
         socket
         |> put_flash(:info, "Slide created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
