defmodule FungusToast.Repo.Migrations.AddMoistureGrowthBoost do
  use Ecto.Migration
  alias FungusToast.Repo
  alias FungusToast.Skills.SkillsSeed

  def change do
    alter table(:players) do
      add :moisture_growth_boost, :float, null: false, default: 2.0
    end

    Repo.delete_all(FungusToast.Games.Skill)
    #reset the identity so the skill ids can match the desired values again
    Repo.query("ALTER SEQUENCE skills_id_seq RESTART")
    SkillsSeed.seed_skills()
  end
end
