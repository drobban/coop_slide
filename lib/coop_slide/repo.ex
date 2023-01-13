defmodule CoopSlide.Repo do
  use Ecto.Repo,
    otp_app: :coop_slide,
    adapter: Ecto.Adapters.Postgres
end
