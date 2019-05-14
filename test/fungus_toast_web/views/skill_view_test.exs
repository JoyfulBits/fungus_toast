defmodule FungusToastWeb.SkillViewTest do
  use FungusToastWeb.ConnCase, async: true
  use Plug.Test
  alias FungusToastWeb.SkillView
  alias FungusToast.Games.Skill

  describe "skill.json" do
    test "that the correct fields get transformed" do
      skill = %Skill{
        id: 1,
        name: "some name",
        up_is_good: true,
        increase_per_point: 3.14
      }

      result = SkillView.render("skill.json", %{skill: skill})

      assert result.id == skill.id
      assert result.name == skill.name
      assert result.up_is_good == skill.up_is_good
      assert result.increase_per_point == skill.increase_per_point
    end
  end
end
