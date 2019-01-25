defmodule FungusToast.Games.Grid do
  @doc ~S"""
  Creates a new grid with empty cells

   ## Examples

   iex> Grid.new(2,2)
   [
     [ %{}, %{} ],
     [ %{}, %{} ]
   ]
  """
  def new(rows, cols, empty \\ %{}), do: 1..cols |> Enum.reduce([], fn _, acc -> acc ++ [row(rows, empty)] end)

  defp row(len, empty), do: 1..len |> Enum.reduce([], fn _, acc -> acc ++ [empty] end)

  @doc ~S"""
  Returns the cell at row, col

   ## Examples


   iex> grid = [[%{foo: "bar"}],[%{}]]
   iex> Grid.at(grid, 0,0)
   %{foo: "bar"}
  """
  def at(grid, row, col), do: grid |> Enum.at(row) |> Enum.at(col)

  @doc ~S"""
  Replaces the cell at row, col with val

   ## Examples


   iex> grid = [[%{}],[%{}]]
   iex> Grid.replace(grid, 0,0, %{foo: "bar"})
   [
     [%{foo: "bar"}],
     [%{}]
   ]
  """
  def replace(grid, row, col, val) do
    new_row =
      Enum.at(grid, row)
      |> List.replace_at(col, val)

    List.replace_at(grid, row, new_row)
  end
end
