defmodule FungusToast.Skills.SkillsSeed do
  alias FungusToast.Skills
  alias FungusToast.Repo

  defp upsert_skill(changes = %{
    id: _,
    name: name,
    description: _,
    increase_per_point: _,
    up_is_good: _,
    number_of_active_cell_changes: _
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
      id: Skills.skill_id_hypermutation,
      name: "Hypermutation",
      description:
        "Increases the chance that you will generate a bonus mutation point during each growth cycle.",
      increase_per_point: 2.0,
      up_is_good: true,
      number_of_active_cell_changes: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_budding,
      name: "Budding",
      description:
        "Increases the chance that your live cells will bud into a corner (top-left, top-right, bottom-left, bottom-right) cell.",
      increase_per_point: 0.4,
      up_is_good: true,
      number_of_active_cell_changes: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_anti_apoptosis,
      name: "Anti-Apoptosis",
      description: "Decreases the chance that your cells will die at random.",
      increase_per_point: 0.25,
      up_is_good: false,
      number_of_active_cell_changes: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_regeneration,
      name: "Regeneration",
      description:
        "Increases the chance that your live cell will regenerate an adjacent dead cell (from any player).",
      increase_per_point: 0.25,
      up_is_good: true,
      number_of_active_cell_changes: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_mycotoxicity,
      name: "Mycotoxicity",
      description:
        "Increases the chance that your live cell will kill an adjacent living cell of another player.",
      increase_per_point: 0.25,
      up_is_good: true,
      number_of_active_cell_changes: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_hydrophilia,
      name: "Hydrophilia",
      description:
        "Increases the chance that your live cell growth into an adjacent moist cell. Also grants 3 water droplets to drop on the toast.",
      increase_per_point: 2.0,
      up_is_good: true,
      number_of_active_cell_changes: 3 #can drop 3 drops of water
    })

    upsert_skill(%{
      id: Skills.skill_id_spores,
      name: "Spores",
      description:
        "Increases the chance that a cell which fails to grow into an adjacent cell will will release spores and grow into a random cell on the grid.",
      increase_per_point: 0.10,
      up_is_good: true,
      number_of_active_cell_changes: 0
    })
  end

  def reset_skills_in_database() do
    Repo.delete_all(FungusToast.Games.Skill)
    #reset the identity so the skill ids can match the desired values again
    Repo.query("ALTER SEQUENCE skills_id_seq RESTART")
    seed_skills()
  end
end
