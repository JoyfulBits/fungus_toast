defmodule FungusToast.Games.GrowthCycle do
  @derive Jason.Encoder
  defstruct generation_number: 0, toast_changes: %{}, mutation_points_earned: %{}
end
