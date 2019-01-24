defmodule FungusToast.Games.Game.EngineTest do
  alias FungusToast.Games.Game.Engine
  use ExUnit.Case, async: true
  doctest Engine

  describe "single player game creation" do
    test "status is in progress with ai players" do
      attrs = %{"number_of_human_players" => 1, "number_of_ai_players" => 1}

      result = Engine.create_state(attrs)

      assert result["status"] == "In Progress"
    end

    test "game state population" do
      attrs = %{"number_of_human_players" => 1, "number_of_ai_players" => 1}

      result = Engine.create_state(attrs)

      assert result["game_state"] != nil
    end

    test "status is finished without ai players" do
      attrs = %{"number_of_human_players" => 1, "number_of_ai_players" => 0}

      result = Engine.create_state(attrs)

      assert result["status"] == "Finished"
    end
  end

  describe "multi player game creation" do
    test "does not modify parameters" do
      attrs = %{"number_of_human_players" => 2}

      result = Engine.create_state(attrs)

      assert attrs == result
    end
  end
end
