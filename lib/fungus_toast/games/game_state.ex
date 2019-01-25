defmodule FungusToast.Games.Game.State do
  @derive Jason.Encoder
  defstruct cells: []

  defmodule Cell do
    @derive Jason.Encoder
    defstruct [:player_id, :cell_type]
  end

  defmodule Grid do
    @doc ~S"""
    Creates a new grid with empty cells

     ## Examples

     iex> Grid.new(2,2)
     [
       [
         %FungusToast.Games.Game.State.Cell{cell_type: nil, player_id: nil},
         %FungusToast.Games.Game.State.Cell{cell_type: nil, player_id: nil}
       ],
       [
         %FungusToast.Games.Game.State.Cell{cell_type: nil, player_id: nil},
         %FungusToast.Games.Game.State.Cell{cell_type: nil, player_id: nil}
       ]
     ]
    """
    def new(rows, cols), do: 1..cols |> Enum.reduce([], fn _, acc -> acc ++ [row(rows)] end)

    defp row(len), do: 1..len |> Enum.reduce([], fn _, acc -> acc ++ [%Cell{}] end)
  end
end
