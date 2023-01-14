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
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:slide, Shows.get_slide!(id))}
  end

  defp apply_action(socket, :add, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Slide")
    |> assign(:slide, Shows.get_slide!(id))
    |> assign(:page, %Page{})
  end

  defp page_title(:show), do: "Show Slide"
  defp page_title(:edit), do: "Edit Slide"
  defp page_title(:add), do: "Appending Slide with page"
end
