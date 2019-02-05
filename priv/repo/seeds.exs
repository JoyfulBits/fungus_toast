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

Accounts.create_user(%{user_name: "Fungus Amungus"})
Games.create_game(%{user_name: "Fungus Amungus", number_of_human_players: 1})

Games.create_skill(%{name: "Hypermutation", description: "Increases the chance that you will generate a bonus mutation point during each growth cycle.", increase_per_point: 1, up_is_good: true})
Games.create_skill(%{name: "Budding", description: "Increases the chance that your live cells will bud into a corner (top-left, top-right, bottom-left, bottom-right) cell.", increase_per_point: 1, up_is_good: true})
Games.create_skill(%{name: "Anti-Apoptosis", description: "Decreases the chance that your cells will die at random.", increase_per_point: 0.5, up_is_good: false})
Games.create_skill(%{name: "Regeneration", description: "Increases the chance that your live cell will regenerate an adjace dead cell (from any player).", increase_per_point: 0.5, up_is_good: true})
Games.create_skill(%{name: "Mycotoxicity", description: "Increases the chance that your live cell will kill an adjacent living cell of another player.", increase_per_point: 1, up_is_good: true})
