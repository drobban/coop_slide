defmodule CoopSlideWeb.SlideLive.Present do
  use CoopSlideWeb, :live_view

  alias CoopSlide.Shows
  alias CoopSlide.Shows.Page

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    pages = Shows.get_slide_pages(id)

    {:noreply,
     socket
     |> assign(:pages, pages)
     |> assign(:slide, Shows.get_slide!(id))
     |> assign(:page_title, page_title(socket.assigns.live_action))}
  end

  defp page_title(:present), do: "Presentation"
  defp page_title(:projector), do: "Projection mode"
  defp page_title(:controller), do: "Control mode"
end
