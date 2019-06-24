defmodule FungusToast.Skills.SkillsSeed do
  alias FungusToast.{Repo, Skills, ActiveSkills}

  defp upsert_skill(changes = %{
    id: _,
    name: name,
    description: _,
    increase_per_point: _,
    up_is_good: _,
    minimum_round: _
  }) do
    skill = Skills.get_skill_by_name(name)
    if(skill == nil) do
      Skills.create_skill(changes)
    else
      Skills.update_skill(skill, changes)
    end

    true
  end

  defp upsert_active_skill(changes = %{
    id: _,
    name: name,
    description: _,
    number_of_toast_changes: _,
    minimum_round: _
  }) do
    skill = ActiveSkills.get_active_skill_by_name(name)
    if(skill == nil) do
      ActiveSkills.create_active_skill(changes)
    else
      ActiveSkills.update_active_skill(skill, changes)
    end

    true
  end

  def seed_skills do
    upsert_skill(%{
      id: Skills.skill_id_hypermutation,
      name: "Hypermutation",
      description:
        "Increases the chance that you will generate a bonus mutation point during each growth cycle.",
      increase_per_point: 2.0,
      up_is_good: true,
      minimum_round: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_budding,
      name: "Budding",
      description:
        "Increases the chance that your live cells will bud into a corner (top-left, top-right, bottom-left, bottom-right) cell.",
      increase_per_point: 0.4,
      up_is_good: true,
      minimum_round: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_anti_apoptosis,
      name: "Anti-Apoptosis",
      description: "Decreases the chance that your cells will die at random.",
      increase_per_point: 0.25,
      up_is_good: false,
      minimum_round: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_regeneration,
      name: "Regeneration",
      description:
        "Increases the chance that your live cell will regenerate an adjacent dead cell (from any player).",
      increase_per_point: 0.25,
      up_is_good: true,
      minimum_round: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_mycotoxicity,
      name: "Mycotoxicity",
      description:
        "Increases the chance that your live cell will kill an adjacent living cell of another player.",
      increase_per_point: 0.25,
      up_is_good: true,
      minimum_round: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_hydrophilia,
      name: "Hydrophilia",
      description:
        "Increases the chance that your live cell growth into an adjacent moist cell.",
      increase_per_point: 4.0,
      up_is_good: true,
      minimum_round: 0
    })

    upsert_skill(%{
      id: Skills.skill_id_spores,
      name: "Spores",
      description:
        "Increases the chance that a cell which fails to grow into an adjacent cell will will release spores and grow into a random cell on the grid.",
      increase_per_point: 0.10,
      up_is_good: true,
      minimum_round: 0
    })

    true
  end

  def seed_active_skills do
    upsert_active_skill(%{
      id: ActiveSkills.skill_id_eye_dropper,
      name: "Eye Dropper",
      description:
        "Allows you to place 3 drops of water on the toast to make it moist.",
      number_of_toast_changes: ActiveSkills.number_of_toast_changes_for_eye_dropper,
      minimum_round: 0
    })

    upsert_active_skill(%{
      id: ActiveSkills.skill_id_dead_cell,
      name: "Dead Cell",
      description:
        "Allows you to place one of your dead cells on any empty space.",
      number_of_toast_changes: ActiveSkills.number_of_toast_changes_for_dead_cell,
      minimum_round: ActiveSkills.minimum_number_of_rounds_for_dead_cell
    })
  end

  def reset_skills_in_database() do
    Repo.delete_all(FungusToast.Games.Skill)
    Repo.delete_all(FungusToast.Games.ActiveSkill)
    #reset the identity so the skill ids can match the desired values again
    Repo.query("ALTER SEQUENCE skills_id_seq RESTART")
    Repo.query("ALTER SEQUENCE active_skills_id_seq RESTART")
    seed_skills()
    seed_active_skills()
  end
end
