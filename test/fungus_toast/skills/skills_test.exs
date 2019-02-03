defmodule FungusToast.SkillsTest do
  use FungusToast.DataCase

  alias FungusToast.Skills

  describe "skills" do
    alias FungusToast.Skills.Skill

    @valid_attrs %{description: "some description", increase_per_point: "120.5", name: "some name", up_is_good: true}
    @update_attrs %{description: "some updated description", increase_per_point: "456.7", name: "some updated name", up_is_good: false}
    @invalid_attrs %{description: nil, increase_per_point: nil, name: nil, up_is_good: nil}

    def skill_fixture(attrs \\ %{}) do
      {:ok, skill} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Skills.create_skill()

      skill
    end

    test "list_skills/0 returns all skills" do
      skill = skill_fixture()
      assert Skills.list_skills() == [skill]
    end

    test "get_skill!/1 returns the skill with given id" do
      skill = skill_fixture()
      assert Skills.get_skill!(skill.id) == skill
    end

    test "create_skill/1 with valid data creates a skill" do
      assert {:ok, %Skill{} = skill} = Skills.create_skill(@valid_attrs)
      assert skill.description == "some description"
      assert skill.increase_per_point == Decimal.new("120.5")
      assert skill.name == "some name"
      assert skill.up_is_good == true
    end

    test "create_skill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Skills.create_skill(@invalid_attrs)
    end

    test "update_skill/2 with valid data updates the skill" do
      skill = skill_fixture()
      assert {:ok, %Skill{} = skill} = Skills.update_skill(skill, @update_attrs)
      assert skill.description == "some updated description"
      assert skill.increase_per_point == Decimal.new("456.7")
      assert skill.name == "some updated name"
      assert skill.up_is_good == false
    end

    test "update_skill/2 with invalid data returns error changeset" do
      skill = skill_fixture()
      assert {:error, %Ecto.Changeset{}} = Skills.update_skill(skill, @invalid_attrs)
      assert skill == Skills.get_skill!(skill.id)
    end

    test "delete_skill/1 deletes the skill" do
      skill = skill_fixture()
      assert {:ok, %Skill{}} = Skills.delete_skill(skill)
      assert_raise Ecto.NoResultsError, fn -> Skills.get_skill!(skill.id) end
    end

    test "change_skill/1 returns a skill changeset" do
      skill = skill_fixture()
      assert %Ecto.Changeset{} = Skills.change_skill(skill)
    end
  end
end
