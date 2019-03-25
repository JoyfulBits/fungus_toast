# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FungusToast.Repo.insert!(%FungusToast.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias FungusToast.{Accounts, Games}
alias FungusToast.Skills.SkillsSeed

Accounts.create_user(%{user_name: "Fungusmotron"})
Accounts.create_user(%{user_name: "Fungus Amungus"})

Games.create_game("Fungus Amungus", %{number_of_human_players: 1})

#create all of the Skills records
SkillsSeed.seed_skills()
