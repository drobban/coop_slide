defmodule CoopSlideWeb.SlideLive.Present do
  use CoopSlideWeb, :live_view

  alias Phoenix.PubSub
  alias CoopSlide.Shows
  alias CoopSlide.Shows.Page

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current, 0)
     |> assign(:video, nil)}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    slide_id = id
    pages = Shows.get_slide_pages(id)

    PubSub.subscribe(CoopSlide.PubSub, "slide_id:#{slide_id}")

    {:noreply,
     socket
     |> assign(:pages, pages)
     |> assign(:slide, Shows.get_slide!(id))
     |> assign(:page_title, page_title(socket.assigns.live_action))}
  end

  def handle_event("video_ready", id, socket) do
    slide_id = socket.assigns.slide.id
    PubSub.broadcast(CoopSlide.PubSub, "slide_id:#{slide_id}", %{video_ready: id})
    {:noreply, socket}
  end

  @impl true
  def handle_info(topic, socket) do
    case socket.assigns.live_action do
      :projector ->
        handle_command(socket, topic)

      :controller ->
        handle_command(socket, topic)

      _ ->
        IO.inspect("Do nothing!")
        {:noreply, socket}
    end
  end

  defp handle_command(socket, %{cmd: cmd}) do
    change_slide(socket, cmd)
  end

  defp handle_command(socket, %{video_ready: id}) do
    {:noreply,
     socket
     |> assign(:video, id)}
  end

  defp change_slide(socket, :forward) do
    current = socket.assigns.current + 1
    pages = socket.assigns.pages

    case Enum.at(pages, current) do
      %CoopSlide.Shows.Page{} = _page ->
        {:noreply,
         socket
         |> assign(:current, current)}

      nil ->
        {:noreply, socket}
    end
  end

  defp change_slide(socket, :backward) do
    current = socket.assigns.current - 1
    pages = socket.assigns.pages

    case Enum.at(pages, current) do
      %CoopSlide.Shows.Page{} = _page when current > -1 ->
        {:noreply,
         socket
         |> assign(:current, current)}

      nil ->
        {:noreply, socket}
    end
  end

  defp page_title(:present), do: "Presentation"
  defp page_title(:projector), do: "Projection mode"
  defp page_title(:controller), do: "Control mode"
end
