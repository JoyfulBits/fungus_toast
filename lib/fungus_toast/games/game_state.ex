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

    @doc ~S"""
    Creates a new grid with empty cells

     ## Examples


     iex> grid = [[%FungusToast.Games.Game.State.Cell{cell_type: 1, player_id: nil}],[%FungusToast.Games.Game.State.Cell{cell_type: nil, player_id: nil}]]
     iex> Grid.at(grid, 0,0)
     %FungusToast.Games.Game.State.Cell{cell_type: 1, player_id: nil}
    """
    def at(grid, row, col), do: grid |> Enum.at(row) |> Enum.at(col)
  end
end
