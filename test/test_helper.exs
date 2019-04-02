ExUnit.start(exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(FungusToast.Repo, {:shared, self()})#:manual)

FungusToast.Skills.SkillsSeed.seed_skills()
