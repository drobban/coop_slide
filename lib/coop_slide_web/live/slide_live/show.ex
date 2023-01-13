defmodule CoopSlideWeb.SlideLive.Show do
  use CoopSlideWeb, :live_view

  alias CoopSlide.Shows

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:slide, Shows.get_slide!(id))}
  end

  defp page_title(:show), do: "Show Slide"
  defp page_title(:edit), do: "Edit Slide"
end
