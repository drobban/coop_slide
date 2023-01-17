defmodule CoopSlideWeb.SlideLive.ControlComponent do
  use CoopSlideWeb, :live_component

  alias Phoenix.PubSub
  alias CoopSlide.Shows

  @impl true
  def update(assigns, socket) do
    slide = assigns.slide
    pages = Shows.get_slide_pages(slide.id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:pages, pages)
     |> assign(:current, 0)
     |> assign(:page, Enum.at(pages, 0))
     |> assign(:next_page, Enum.at(pages, 1))
     |> assign(:prev_page, nil)}
  end

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

  def handle_event("change_slide", %{"command" => cmd}, socket) do
    case cmd do
      "prev" ->
        change_slide(socket, :backward)

      "next" ->
        change_slide(socket, :forward)

      _ ->
        {:noreply, socket}
    end
  end

  defp change_slide(socket, :forward) do
    current = socket.assigns.current + 1
    pages = socket.assigns.pages
    slide_id = socket.assigns.slide.id
    PubSub.broadcast(CoopSlide.PubSub, "slide_id:#{slide_id}", %{cmd: :forward})

    case Enum.at(pages, current) do
      %CoopSlide.Shows.Page{} = page ->
        {:noreply,
         socket
         |> assign(:current, current)
         |> assign(:prev_page, Enum.at(pages, current - 1))
         |> assign(:page, page)
         |> assign(:next_page, Enum.at(pages, current + 1))}

      nil ->
        {:noreply, socket}
    end
  end

  defp change_slide(socket, :backward) do
    current = socket.assigns.current - 1
    pages = socket.assigns.pages

    slide_id = socket.assigns.slide.id
    PubSub.broadcast(CoopSlide.PubSub, "slide_id:#{slide_id}", %{cmd: :backward})

    case Enum.at(pages, current) do
      %CoopSlide.Shows.Page{} = page when current > -1 ->
        prev = if current == 0, do: nil, else: Enum.at(pages, current - 1)

        {:noreply,
         socket
         |> assign(:current, current)
         |> assign(:prev_page, prev)
         |> assign(:page, page)
         |> assign(:next_page, Enum.at(pages, current + 1))}

      nil ->
        {:noreply, socket}
    end
  end
end
