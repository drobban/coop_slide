defmodule CoopSlide.ShowsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CoopSlide.Shows` context.
  """

  @doc """
  Generate a slide.
  """
  def slide_fixture(attrs \\ %{}) do
    {:ok, slide} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> CoopSlide.Shows.create_slide()

    slide
  end

  @doc """
  Generate a page.
  """
  def page_fixture(attrs \\ %{}) do
    {:ok, page} =
      attrs
      |> Enum.into(%{
        content: "some content",
        order: 42
      })
      |> CoopSlide.Shows.create_page()

    page
  end
end
