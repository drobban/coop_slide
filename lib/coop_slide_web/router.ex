defmodule CoopSlideWeb.Router do
  use CoopSlideWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CoopSlideWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :file_handler do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CoopSlideWeb.LayoutView, :root}
    plug :put_secure_browser_headers
  end

  scope "/", CoopSlideWeb do
    pipe_through :file_handler

    resources "/uploads", UploadController, only: [:index, :new, :create]
    get "/uploads/:slide_id/:id", UploadController, :show
    post "/list_uploads", UploadController, :index
  end

  scope "/", CoopSlideWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/slides", SlideLive.Index, :index
    live "/slides/new", SlideLive.Index, :new
    live "/slides/:id/edit", SlideLive.Index, :edit

    live "/slides/:id", SlideLive.Show, :show
    live "/slides/:id/page/:page_id", SlideLive.Show, :edit_page
    live "/slides/:id/show/add", SlideLive.Show, :add
    live "/slides/:id/show/edit", SlideLive.Show, :edit
    live "/slides/:id/present", SlideLive.Present, :present
    live "/slides/:id/projector", SlideLive.Present, :projector
    live "/slides/:id/control", SlideLive.Present, :controller

    live "/pages", PageLive.Index, :index
    live "/pages/new", PageLive.Index, :new
    live "/pages/:id/edit", PageLive.Index, :edit

    live "/pages/:id", PageLive.Show, :show
    live "/pages/:id/show/edit", PageLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", CoopSlideWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CoopSlideWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
