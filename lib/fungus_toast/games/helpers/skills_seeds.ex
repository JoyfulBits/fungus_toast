defmodule FungusToast.Skills.SkillsSeed do
  alias FungusToast.Games

  def seed_skills do
    Games.create_skill(%{
      name: "Hypermutation",
      description:
        "Increases the chance that you will generate a bonus mutation point during each growth cycle.",
      increase_per_point: 2.0,
      up_is_good: true
    })

    Games.create_skill(%{
      name: "Budding",
      description:
        "Increases the chance that your live cells will bud into a corner (top-left, top-right, bottom-left, bottom-right) cell.",
      increase_per_point: 0.5,
      up_is_good: true
    })

    Games.create_skill(%{
      name: "Anti-Apoptosis",
      description: "Decreases the chance that your cells will die at random.",
      increase_per_point: 0.5,
      up_is_good: false
    })

    Games.create_skill(%{
      name: "Regeneration",
      description:
        "Increases the chance that your live cell will regenerate an adjacent dead cell (from any player).",
      increase_per_point: 0.25,
      up_is_good: true
    })

    Games.create_skill(%{
      name: "Mycotoxicity",
      description:
        "Increases the chance that your live cell will kill an adjacent living cell of another player.",
      increase_per_point: 0.5,
      up_is_good: true
    })
  end
end
