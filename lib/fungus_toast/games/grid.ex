defmodule FungusToast.Games.Grid do
  defmodule Cell do
    @derive Jason.Encoder
    defstruct [:player_id, :cell_type]
  end

  @doc ~S"""
  Creates a new grid with empty cells

   ## Examples

   iex> Grid.new(2,2)
   [
     [
       %FungusToast.Games.Grid.Cell{cell_type: nil, player_id: nil},
       %FungusToast.Games.Grid.Cell{cell_type: nil, player_id: nil}
     ],
     [
       %FungusToast.Games.Grid.Cell{cell_type: nil, player_id: nil},
       %FungusToast.Games.Grid.Cell{cell_type: nil, player_id: nil}
     ]
   ]
  """
  def new(rows, cols), do: 1..cols |> Enum.reduce([], fn _, acc -> acc ++ [row(rows)] end)

  defp row(len), do: 1..len |> Enum.reduce([], fn _, acc -> acc ++ [%Cell{}] end)

  @doc ~S"""
  Returns the cell at row, col

   ## Examples


   iex> grid = [[%FungusToast.Games.Grid.Cell{cell_type: 1, player_id: nil}],[%FungusToast.Games.Grid.Cell{cell_type: nil, player_id: nil}]]
   iex> Grid.at(grid, 0,0)
   %FungusToast.Games.Grid.Cell{cell_type: 1, player_id: nil}
  """
  def at(grid, row, col), do: grid |> Enum.at(row) |> Enum.at(col)

  @doc ~S"""
  Replaces the cell at row, col with val

   ## Examples


   iex> grid = [[%FungusToast.Games.Grid.Cell{cell_type: 1, player_id: nil}],[%FungusToast.Games.Grid.Cell{cell_type: nil, player_id: nil}]]
   iex> Grid.replace(grid, 0,0, %FungusToast.Games.Grid.Cell{cell_type: 10, player_id: 100})
   [
     [%FungusToast.Games.Grid.Cell{cell_type: 10, player_id: 100}],
     [%FungusToast.Games.Grid.Cell{cell_type: nil, player_id: nil}]
   ]
  """
  def replace(grid, row, col, val) do
    new_row =
      Enum.at(grid, row)
      |> List.replace_at(col, val)

    List.replace_at(grid, row, new_row)
  end
end
