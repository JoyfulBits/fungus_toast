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
  def new(rows, cols, empty \\ %{}),
    do: 1..cols |> Enum.reduce([], fn _, acc -> acc ++ [row(rows, empty)] end)

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
  Returns the cell at flat_index

   ## Examples


   iex> grid = [[%{a: 0}, %{a: 1}, %{a: 2}],[%{b: 0}, %{b: 1}, %{b: 2}]]
   iex> Grid.at(grid ,3)
   %{b: 0}
  """
  def at(grid, flat_index), do: List.flatten(grid) |> Enum.at(flat_index)

  @doc ~S"""
  Replaces the cell at row, col with val

   ## Examples


   iex> grid = [[%{}],[%{}]]
   iex> Grid.replace(grid, 0,0, %{foo: "bar"})
   [ [%{foo: "bar"}], [%{}] ]
  """
  def replace(grid, row, col, val) do
    new_row =
      Enum.at(grid, row)
      |> List.replace_at(col, val)

    List.replace_at(grid, row, new_row)
  end

  @doc ~S"""
  Replaces the cell at flat_index with val

   ## Examples


   iex> grid = [[%{a: 0}, %{a: 1}, %{a: 2}],[%{b: 0}, %{b: 1}, %{b: 2}]]
   iex> Grid.replace(grid, 3, %{foo: "bar"})
   [[%{a: 0}, %{a: 1}, %{a: 2}], [%{foo: "bar"}, %{b: 1}, %{b: 2}]]
  """
  def replace(grid, flat_index, val) do
    columns = grid |> List.first() |> length
    col = Integer.mod(flat_index, columns)
    row = Integer.floor_div(flat_index, columns)
    replace(grid, row, col, val)
  end
end
