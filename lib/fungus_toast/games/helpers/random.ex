defmodule FungusToast.Random do
    @doc """
    Takes a percentage chance (float value) and returns true if that percentage chance randomly hits
    """
    @spec random_chance_hit(float()) :: boolean()
    def random_chance_hit(percent_chance) do
        Enum.random(0..9999) < percent_chance * 100
    end
end