{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start(exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(FungusToast.Repo, {:shared, self()})

FungusToast.Skills.SkillsSeed.reset_skills_in_database()

