defmodule FungusToast.Games.SkillPrerequisiteTest do
  use ExUnit.Case, async: true
  alias FungusToast.Games.SkillPrerequisite

  describe "changeset/2" do
    test "a valid changeset" do
        assert %{valid?: true} = SkillPrerequisite.changeset(%SkillPrerequisite{}, %{skill_id: 1, required_skill_id: 2, required_skill_level: 3})
    end

    test "a failing changeset" do
       assert %{valid?: false} = SkillPrerequisite.changeset(%SkillPrerequisite{}, %{})
    end
  end
end
