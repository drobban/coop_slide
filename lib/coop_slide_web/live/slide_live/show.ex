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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    page = Shows.get_page!(id)
    slide = socket.assigns.slide
    {:ok, _} = Shows.delete_page(page)

    {:noreply,
     socket
     |> push_redirect(
       to: CoopSlideWeb.Router.Helpers.slide_show_path(CoopSlideWeb.Endpoint, :show, slide)
     )}
  end

  @impl true
  def handle_event("move_up", %{"id" => id}, socket) do
    page = Shows.get_page!(id)
    pages = socket.assigns.pages
    slide = socket.assigns.slide
    # {:ok, _} = Shows.delete_page(page)
    idx = Enum.find_index(pages, fn p -> page == p end)

    case {Enum.at(pages, idx - 1), Enum.at(pages, idx)} do
      {p1, p2} when idx - 1 > -1 ->
        Shows.update_page(p1, %{order: p2.order})
        Shows.update_page(p2, %{order: p1.order})

      _ ->
        # Shouldnt happen.
        IO.inspect("do nothing")
    end

    {:noreply,
     socket
     |> assign(:pages, Shows.get_slide_pages(slide.id))}
  end

  @impl true
  def handle_event("move_down", %{"id" => id}, socket) do
    page = Shows.get_page!(id)
    pages = socket.assigns.pages
    slide = socket.assigns.slide
    idx = Enum.find_index(pages, fn p -> page == p end)

    case {Enum.at(pages, idx), Enum.at(pages, idx + 1)} do
      {p, nil} ->
        IO.inspect("do nothing")

      {p1, p2} ->
        Shows.update_page(p1, %{order: p2.order})
        Shows.update_page(p2, %{order: p1.order})
    end

    {:noreply,
     socket
     |> assign(:pages, Shows.get_slide_pages(slide.id))}
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
