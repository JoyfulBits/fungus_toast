defmodule FungusToast.Random do
    @spec random_chance_hit(float()) :: boolean()
    def random_chance_hit(percent_chance) do
        Enum.random(0..9999) < percent_chance * 100
    end
end