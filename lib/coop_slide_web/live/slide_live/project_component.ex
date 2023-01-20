defmodule CoopSlideWeb.SlideLive.ProjectComponent do
  use CoopSlideWeb, :live_component

  alias CoopSlide.Shows

  @impl true
  def update(%{current: current} = assigns, socket) do
    slide = assigns.slide
    pages = Shows.get_slide_pages(slide.id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:pages, pages)
     |> assign(:current, current)
     |> assign(:page, Enum.at(pages, current))}
  end

  @impl true
  def handle_event("change_slide", %{"key" => key}, socket) do
    case key do
      "ArrowRight" ->
        change_slide(socket, :forward)

      "ArrowLeft" ->
        change_slide(socket, :backward)

      "Escape" ->
        {:noreply,
         socket
         |> push_redirect(to: socket.assigns.return_to)}

      _ ->
        {:noreply, socket}
    end
  end

  defp change_slide(socket, :forward) do
    current = socket.assigns.current + 1

    {new_current, new_page} =
      case Enum.at(socket.assigns.pages, current) do
        %CoopSlide.Shows.Page{} = page ->
          {current, page}

        nil ->
          {socket.assigns.current, socket.assigns.page}
      end

    {:noreply,
     socket
     |> assign(:current, new_current)
     |> assign(:page, new_page)}
  end

  defp change_slide(socket, :backward) do
    current = socket.assigns.current - 1

    {new_current, new_page} =
      case current do
        x when x > -1 ->
          {x, Enum.at(socket.assigns.pages, x)}

        _ ->
          {socket.assigns.current, socket.assigns.page}
      end

    {:noreply,
     socket
     |> assign(:current, new_current)
     |> assign(:page, new_page)}
  end
end
