#This exists only as a convenience to copy/paste into iex
alias FungusToast.{Repo, Accounts, Players, Games, Skills, PlayerSkills, Rounds, AiStrategies}
alias FungusToast.Accounts.User
alias FungusToast.Games.{Game, Player, Grid, GridCell}

#for creating a real user and game
{:ok, user} = Accounts.create_user(%{user_name: "user 2019-04-26.01"})
game = Games.create_game(user.user_name, %{number_of_human_players: 1, number_of_ai_players: 1})

#for creating an empty game
game = FungusToast.Games.Game.changeset(%FungusToast.Games.Game{}, %{number_of_human_players: 1, number_of_ai_players: 1}) |> Repo.insert!
