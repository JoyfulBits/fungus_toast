defmodule FungusToast.Skills.SkillsSeed do
  alias FungusToast.Skills

  defp upsert_skill(changes = %{
    id: _,
    name: name,
    description: _,
    increase_per_point: _,
    up_is_good: _
  }) do
    skill = Skills.get_skill_by_name(name)
    if(skill == nil) do
      Skills.create_skill(changes)
    else
      Skills.update_skill(skill, changes)
    end
  end

  def seed_skills do
    upsert_skill(%{
      id: 1,
      name: "Hypermutation",
      description:
        "Increases the chance that you will generate a bonus mutation point during each growth cycle.",
      increase_per_point: 3.0,
      up_is_good: true
    })


    upsert_skill(%{
      id: 2,
      name: "Budding",
      description:
        "Increases the chance that your live cells will bud into a corner (top-left, top-right, bottom-left, bottom-right) cell.",
      increase_per_point: 0.4,
      up_is_good: true
    })

    upsert_skill(%{
      id: 3,
      name: "Anti-Apoptosis",
      description: "Decreases the chance that your cells will die at random.",
      increase_per_point: 0.25,
      up_is_good: false
    })

    upsert_skill(%{
      id: 4,
      name: "Regeneration",
      description:
        "Increases the chance that your live cell will regenerate an adjacent dead cell (from any player).",
      increase_per_point: 0.25,
      up_is_good: true
    })

    upsert_skill(%{
      id: 5,
      name: "Mycotoxicity",
      description:
        "Increases the chance that your live cell will kill an adjacent living cell of another player.",
      increase_per_point: 0.25,
      up_is_good: true
    })
  end
end
