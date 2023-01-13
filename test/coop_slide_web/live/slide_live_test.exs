defmodule CoopSlideWeb.SlideLiveTest do
  use CoopSlideWeb.ConnCase

  import Phoenix.LiveViewTest
  import CoopSlide.ShowsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_slide(_) do
    slide = slide_fixture()
    %{slide: slide}
  end

  describe "Index" do
    setup [:create_slide]

    test "lists all slides", %{conn: conn, slide: slide} do
      {:ok, _index_live, html} = live(conn, Routes.slide_index_path(conn, :index))

      assert html =~ "Listing Slides"
      assert html =~ slide.name
    end

    test "saves new slide", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.slide_index_path(conn, :index))

      assert index_live |> element("a", "New Slide") |> render_click() =~
               "New Slide"

      assert_patch(index_live, Routes.slide_index_path(conn, :new))

      assert index_live
             |> form("#slide-form", slide: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#slide-form", slide: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.slide_index_path(conn, :index))

      assert html =~ "Slide created successfully"
      assert html =~ "some name"
    end

    test "updates slide in listing", %{conn: conn, slide: slide} do
      {:ok, index_live, _html} = live(conn, Routes.slide_index_path(conn, :index))

      assert index_live |> element("#slide-#{slide.id} a", "Edit") |> render_click() =~
               "Edit Slide"

      assert_patch(index_live, Routes.slide_index_path(conn, :edit, slide))

      assert index_live
             |> form("#slide-form", slide: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#slide-form", slide: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.slide_index_path(conn, :index))

      assert html =~ "Slide updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes slide in listing", %{conn: conn, slide: slide} do
      {:ok, index_live, _html} = live(conn, Routes.slide_index_path(conn, :index))

      assert index_live |> element("#slide-#{slide.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#slide-#{slide.id}")
    end
  end

  describe "Show" do
    setup [:create_slide]

    test "displays slide", %{conn: conn, slide: slide} do
      {:ok, _show_live, html} = live(conn, Routes.slide_show_path(conn, :show, slide))

      assert html =~ "Show Slide"
      assert html =~ slide.name
    end

    test "updates slide within modal", %{conn: conn, slide: slide} do
      {:ok, show_live, _html} = live(conn, Routes.slide_show_path(conn, :show, slide))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Slide"

      assert_patch(show_live, Routes.slide_show_path(conn, :edit, slide))

      assert show_live
             |> form("#slide-form", slide: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#slide-form", slide: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.slide_show_path(conn, :show, slide))

      assert html =~ "Slide updated successfully"
      assert html =~ "some updated name"
    end
  end
end
