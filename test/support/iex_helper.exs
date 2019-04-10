#This exists only as a convenience to copy/paste into iex
alias FungusToast.{Repo, Accounts, Players, Games, Skills, PlayerSkills, Rounds}
alias FungusToast.Accounts.User
alias FungusToast.Games.{Game, Player, Grid, GridCell}


game = FungusToast.Games.Game.changeset(%FungusToast.Games.Game{}, %{number_of_human_players: 1, number_of_ai_players: 1}) |> Repo.insert!
