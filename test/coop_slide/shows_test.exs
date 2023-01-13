defmodule CoopSlide.ShowsTest do
  use CoopSlide.DataCase

  alias CoopSlide.Shows

  describe "slides" do
    alias CoopSlide.Shows.Slide

    import CoopSlide.ShowsFixtures

    @invalid_attrs %{name: nil}

    test "list_slides/0 returns all slides" do
      slide = slide_fixture()
      assert Shows.list_slides() == [slide]
    end

    test "get_slide!/1 returns the slide with given id" do
      slide = slide_fixture()
      assert Shows.get_slide!(slide.id) == slide
    end

    test "create_slide/1 with valid data creates a slide" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Slide{} = slide} = Shows.create_slide(valid_attrs)
      assert slide.name == "some name"
    end

    test "create_slide/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shows.create_slide(@invalid_attrs)
    end

    test "update_slide/2 with valid data updates the slide" do
      slide = slide_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Slide{} = slide} = Shows.update_slide(slide, update_attrs)
      assert slide.name == "some updated name"
    end

    test "update_slide/2 with invalid data returns error changeset" do
      slide = slide_fixture()
      assert {:error, %Ecto.Changeset{}} = Shows.update_slide(slide, @invalid_attrs)
      assert slide == Shows.get_slide!(slide.id)
    end

    test "delete_slide/1 deletes the slide" do
      slide = slide_fixture()
      assert {:ok, %Slide{}} = Shows.delete_slide(slide)
      assert_raise Ecto.NoResultsError, fn -> Shows.get_slide!(slide.id) end
    end

    test "change_slide/1 returns a slide changeset" do
      slide = slide_fixture()
      assert %Ecto.Changeset{} = Shows.change_slide(slide)
    end
  end
end
