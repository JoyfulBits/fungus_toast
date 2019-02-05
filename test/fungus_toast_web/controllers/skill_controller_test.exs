defmodule FungusToastWeb.SkillControllerTest do
  use FungusToastWeb.ConnCase

  alias FungusToast.Games
  alias FungusToast.Games.Skill

  @create_attrs %{
    description: "some description",
    increase_per_point: "120.5",
    name: "some name",
    up_is_good: true
  }
  @update_attrs %{
    description: "some updated description",
    increase_per_point: "456.7",
    name: "some updated name",
    up_is_good: false
  }
  @invalid_attrs %{description: nil, increase_per_point: nil, name: nil, up_is_good: nil}

  def fixture(:skill) do
    {:ok, skill} = Games.create_skill(@create_attrs)
    skill
  end

  defp create_skill(_) do
    skill = fixture(:skill)
    {:ok, skill: skill}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all skills", %{conn: conn} do
      conn = get(conn, Routes.skill_path(conn, :index))
      assert json_response(conn, 200) == []
    end
  end

  describe "create skill" do
    test "renders skill when data is valid", %{conn: conn} do
      conn = post(conn, Routes.skill_path(conn, :create), skill: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.skill_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "increasePerPoint" => 120.5,
               "name" => "some name",
               "upIsGood" => true
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.skill_path(conn, :create), skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update skill" do
    setup [:create_skill]

    test "renders skill when data is valid", %{conn: conn, skill: %Skill{id: id} = skill} do
      conn = put(conn, Routes.skill_path(conn, :update, skill), skill: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.skill_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "increasePerPoint" => 456.7,
               "name" => "some updated name",
               "upIsGood" => false
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, skill: skill} do
      conn = put(conn, Routes.skill_path(conn, :update, skill), skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete skill" do
    setup [:create_skill]

    test "deletes chosen skill", %{conn: conn, skill: skill} do
      conn = delete(conn, Routes.skill_path(conn, :delete, skill))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.skill_path(conn, :show, skill))
      end
    end
  end
end
