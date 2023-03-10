defmodule CoopSlideWeb.SlideLive.Present do
  use CoopSlideWeb, :live_view

  alias Phoenix.PubSub
  alias CoopSlide.Shows
  alias CoopSlide.Accounts

  @impl true
  def mount(_params, session, socket) do
    # %{"user_token" => user_token}
    user_token = Map.get(session, "user_token")
    IO.inspect(user_token)

    user_id =
      if user_token do
        Accounts.get_user_by_session_token(user_token)
        |> Map.get(:id)
      else
        nil
      end

    {:ok,
     socket
     |> assign(:user_id, user_id)
     |> assign(:current, 0)
     |> assign(:video, nil)}
  end

  @impl true
  def handle_params(%{"id" => id} = _params, _, socket) do
    slide_id = id
    pages = Shows.get_slide_pages(id)

    user_id = socket.assigns.user_id

    PubSub.subscribe(CoopSlide.PubSub, "slide_id:#{slide_id}_user:#{user_id}")

    case socket.assigns.live_action do
      :controller ->
        PubSub.broadcast(
          CoopSlide.PubSub,
          "slide_id:#{slide_id}_user:#{user_id}",
          :get_current_slide
        )

      _ ->
        nil
    end

    {:noreply,
     socket
     |> assign(:pages, pages)
     |> assign(:slide, Shows.get_slide!(id))
     |> assign(:page_title, page_title(socket.assigns.live_action))}
  end

  @impl true
  def handle_event("video_ready", id, socket) do
    user_id = socket.assigns.user_id
    slide_id = socket.assigns.slide.id

    PubSub.broadcast(CoopSlide.PubSub, "slide_id:#{slide_id}_user:#{user_id}", %{
      video_ready: id
    })

    {:noreply, socket}
  end

  @impl true
  def handle_info(topic, socket) do
    case socket.assigns.live_action do
      :projector ->
        handle_command(topic, socket)

      :controller ->
        handle_command(topic, socket)

      _ ->
        IO.inspect("Do nothing!")
        {:noreply, socket}
    end
  end

  defp handle_command(:get_current_slide, socket) do
    slide_id = socket.assigns.slide.id
    user_id = socket.assigns.user_id

    case socket.assigns.live_action do
      :projector ->
        IO.inspect("Message recieved")
        PubSub.broadcast(
          CoopSlide.PubSub,
          "slide_id:#{slide_id}_user:#{user_id}",
          %{current_slide: socket.assigns.current}
        )

      _ ->
        nil
    end

    {:noreply, socket}
  end

  defp handle_command(%{current_slide: current}, socket) do

    case socket.assigns.live_action do
      :projector ->
        {:noreply, socket}
      :controller ->
        IO.inspect("Setting currrent to: #{current}")
        {:noreply, socket |> assign(:current, current)}

      _ ->
        {:noreply, socket}
    end
  end

  defp handle_command(%{project_cmd: :toggle_player}, socket) do
    if socket.assigns.live_action == :projector do
      {:noreply, push_event(socket, "toggle-player", %{data: nil})}
    else
      {:noreply, socket}
    end
  end

  defp handle_command(%{cmd: cmd}, socket) do
    change_slide(socket, cmd)
  end

  defp handle_command(%{video_ready: %{"idx" => current, "video_title" => title}}, socket) do
    {:noreply,
     socket
     |> assign(:video, %{idx: String.to_integer(current), title: title})}
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
