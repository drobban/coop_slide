defmodule CoopSlideWeb.SlideLive.Show do
  use CoopSlideWeb, :live_view

  alias CoopSlide.Shows
  alias CoopSlide.Shows.Page

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page, %Page{})

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id, "page_id" => page_id} = params, _, socket) do
    pages = Shows.get_slide_pages(id)
    page = Shows.get_page!(page_id)

    {:noreply,
     socket
     |> assign(:pages, pages)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:page, page)
     |> assign(:slide, Shows.get_slide!(id))}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    pages = Shows.get_slide_pages(id)

    {:noreply,
     socket
     |> assign(:pages, pages)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:slide, Shows.get_slide!(id))}
  end

  defp apply_action(socket, :add, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Slide")
    |> assign(:slide, Shows.get_slide!(id))
    |> assign(:page, %Page{})
  end

  defp apply_action(socket, :edit_page, %{"id" => id, "page_id" => page_id}) do
    socket
    |> assign(:page_title, "Edit page")
    |> assign(:slide, Shows.get_slide!(id))
    |> assign(:page, Shows.get_page!(page_id))
  end

  defp page_title(:show), do: "Show Slide"
  defp page_title(:edit), do: "Edit Slide"
  defp page_title(:add), do: "Appending Slide with page"
  defp page_title(:edit_page), do: "Editing page"
end
