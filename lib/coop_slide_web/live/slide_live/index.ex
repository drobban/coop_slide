defmodule CoopSlideWeb.SlideLive.Index do
  use CoopSlideWeb, :live_view

  alias CoopSlide.Shows
  alias CoopSlide.Shows.Slide

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :slides, list_slides())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Slide")
    |> assign(:slide, Shows.get_slide!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Slide")
    |> assign(:slide, %Slide{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Slides")
    |> assign(:slide, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    slide = Shows.get_slide!(id)
    {:ok, _} = Shows.delete_slide(slide)

    {:noreply, assign(socket, :slides, list_slides())}
  end

  defp list_slides do
    Shows.list_slides()
  end
end
