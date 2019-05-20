defmodule FungusToastWeb.JoinedGameView do
  use FungusToastWeb, :view

  def result_type_joined_but_game_not_started, do: 1
  def result_type_joined_and_game_started, do: 2
  def result_type_game_full, do: 3
  def result_type_user_already_in_game, do: 4

  def render("show.json", %{result: next_round_available}) do
    if(next_round_available) do
      %{result_type: result_type_joined_and_game_started()}
    else
      %{result_type: result_type_joined_but_game_not_started()}
    end
  end

  def render("game_full.json", %{}) do
    %{result_type: result_type_game_full()}
  end

  def render("user_already_joined.json", %{}) do
    %{result_type: result_type_user_already_in_game()}
  end
end
