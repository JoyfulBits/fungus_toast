defmodule FungusToast.Games.Game.EngineTest do
  alias FungusToast.Games.Game.Engine
  use ExUnit.Case, async: true
  doctest Engine

  describe "single player game creation" do
    test "starting state is in progress" do
      attrs = %{"number_of_human_players" => 1, "number_of_ai_players" => 1}

      result = Engine.create_state(attrs)

      assert result["status"] == "In Progress"
    end
  end
end
