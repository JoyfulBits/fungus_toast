defmodule FungusToast.Games.CellGrower do
  alias FungusToast.Random
  alias FungusToast.Games.{Game, Player, GridCell}

  @starvation_death_chance 10.0
  @minimum_live_cells_for_apoptosis 8
  def minimum_live_cells_for_apoptosis, do: @minimum_live_cells_for_apoptosis

  @doc ~S"""
    Iterates over surrounding cells calculating new growths, regenerations, and deaths. Returns GridCells that changed
  """
  @spec calculate_cell_growth(map(), integer(), map(), %Player{}, integer()) :: map()
  def calculate_cell_growth(toast_grid_map, number_of_grid_cells, surrounding_cells, player, light_level) do
    grown_cells = Enum.map(surrounding_cells, fn {k,v} -> process_cell(k, v, player, light_level) end)
      |> Enum.filter(fn x -> x != nil end)
      |> Enum.into(%{}, fn grid_cell -> {grid_cell.index, grid_cell} end)

      if(grown_cells == %{}) do
        new_spores_cell = try_spore_growth(toast_grid_map, number_of_grid_cells, player)
        if(new_spores_cell == nil) do
          %{}
        else
          %{new_spores_cell.index => new_spores_cell}
        end
      else
        grown_cells
      end
  end

  def process_cell(position, grid_cell, player, light_level) do
    if(grid_cell.empty) do
      try_growing_cell(position, grid_cell.index, grid_cell.moist, player, light_level)
    else
      if(grid_cell.live) do
        check_for_mycotoxin_murder(grid_cell, player)
      else
        if(!grid_cell.out_of_grid) do
          check_for_regeneration(grid_cell, player)
        end
      end
    end
  end

  @doc ~S"""
  Returns a new %GridCell{} on a random spot on the toast if the spores_chance hits and if the random cell location is open. Returns nil otherwise.

  ## Examples

  #it returns nil if the spore chance doesn't hit
  iex> CellGrower.try_spore_growth(%{}, 100, %FungusToast.Games.Player{spores_chance: 0})
  nil

  #it returns nil if the spore chance hits but the random location is occupied
  iex> CellGrower.try_spore_growth(%{0 => %FungusToast.Games.GridCell{ index: 0 }}, 1, %FungusToast.Games.Player{spores_chance: 100})
  nil
  """
  def try_spore_growth(toast_grid_map, number_of_grid_cells, player) do
    if(Random.random_chance_hit(player.spores_chance)) do
      spore_index = Enum.random(0..number_of_grid_cells - 1)
      existing_cell = Map.get(toast_grid_map, spore_index)
      if(existing_cell == nil) do
        %GridCell{index: spore_index, live: true, empty: false, moist: false, out_of_grid: false, player_id: player.id}
      end
    end
  end

  @doc ~S"""
  Returns a %GridCell{} if the growth chance corresponding to the cell position hits. Returns nil otherwise.

  ## Examples

  #it generates a new live cell with that player's id if the growth percentage hits
  iex> CellGrower.try_growing_cell(:right_cell, 0, false, %FungusToast.Games.Player{right_growth_chance: 100, id: 1}, 50)
  %FungusToast.Games.GridCell{
    empty: false,
    index: 0,
    live: true,
    out_of_grid: false,
    player_id: 1,
    previous_player_id: nil
  }

  #it generates a new live cell with that player's id if the cell is moist and the player's moisture_growth_boost hits
  iex> CellGrower.try_growing_cell(:right_cell, 0, true, %FungusToast.Games.Player{right_growth_chance: 0, moisture_growth_boost: 100, id: 1}, 50)
  %FungusToast.Games.GridCell{
    empty: false,
    index: 0,
    live: true,
    moist: false,
    out_of_grid: false,
    player_id: 1,
    previous_player_id: nil
  }

  #it returns nil if the growth chance didn't hit
  iex> CellGrower.try_growing_cell(:right_cell, 0, false, %FungusToast.Games.Player{right_growth_chance: 0, id: 1}, 50)
  nil

  """
  @spec try_growing_cell(atom(), integer(), boolean(), %Player{}, integer()) :: map()
  def try_growing_cell(position, cell_index, moist, player, light_level) do
    {:ok, growth_attribute} = Map.fetch(Player.position_to_attribute_map, position)
    {:ok, growth_chance} = Map.fetch(player, growth_attribute)
    bonus_growth_chance = if(moist) do
      player.moisture_growth_boost
    else
      0.0
    end

    bonus_growth_chance = bonus_growth_chance + get_light_level_growth_adjustment(light_level)

    if(Random.random_chance_hit(growth_chance + bonus_growth_chance)) do
      %GridCell{index: cell_index, live: true, empty: false, moist: false, out_of_grid: false, player_id: player.id}
    end
  end

   @doc ~S"""
  Returns a %GridCell{} if the growth chance corresponding to the cell position hits. Returns nil otherwise.

  ## Examples

  #it returns 0 if the light level is the default value
  iex> CellGrower.get_light_level_growth_adjustment(FungusToast.Games.Game.default_light_level())
  0.0

  #it returns 0.2 if the light level is reduced by 1
  iex> CellGrower.get_light_level_growth_adjustment(FungusToast.Games.Game.default_light_level() - 1)
  0.2

  #it returns -0.2 if the light level is increased by 1
  iex> CellGrower.get_light_level_growth_adjustment(FungusToast.Games.Game.default_light_level() + 1)
  -0.2

  #it returns 10.0 if the light level is decreased by 50
  iex> CellGrower.get_light_level_growth_adjustment(FungusToast.Games.Game.default_light_level() - 50)
  10.0

  #it returns -10.0 if the light level is increased by 50
  iex> CellGrower.get_light_level_growth_adjustment(FungusToast.Games.Game.default_light_level() + 50)
  -10.0
  """
  def get_light_level_growth_adjustment(light_level) do
    (Game.default_light_level() - light_level) * 0.2
  end

  @doc ~S"""
  Returns a murdered %GridCell{} if the target cell is an enemy's live cell and the mycotoxin fungicide chance hits. Returns nil otherwise.

  ## Examples

  #it kills the cell if the target cell is an enemy's live cell and the mycotoxin fungicide chance hits
  iex> CellGrower.check_for_mycotoxin_murder(%FungusToast.Games.GridCell{live: true, empty: false, index: 0, player_id: 1}, %FungusToast.Games.Player{mycotoxin_fungicide_chance: 100, id: 2})
  %FungusToast.Games.GridCell{
    empty: false,
    index: 0,
    live: false,
    out_of_grid: false,
    player_id: 1,
    previous_player_id: nil,
    killed_by: 2
  }

    #it returns nil if the cell is the current player's cell
    iex> CellGrower.check_for_mycotoxin_murder(%FungusToast.Games.GridCell{live: true, player_id: 1}, %FungusToast.Games.Player{mycotoxin_fungicide_chance: 100, id: 1})
    nil

    #it returns nil if the mycotoxin_fungicide_chance chance doesn't hit
    iex> CellGrower.check_for_mycotoxin_murder(%FungusToast.Games.GridCell{live: true, player_id: 1}, %FungusToast.Games.Player{mycotoxin_fungicide_chance: 0, id: 2})
    nil

  """
  def check_for_mycotoxin_murder(grid_cell, player) do
    if(grid_cell.player_id != player.id and Random.random_chance_hit(player.mycotoxin_fungicide_chance)) do
      grid_cell = %{grid_cell | live: false}
      %{grid_cell | killed_by: player.id}
    end
  end

  @doc ~S"""
  Returns a live %GridCell{} with the player's id and previous player id set if the regeneration chance hits. Returns nil otherwise.

  ## Examples

  #it revives the dead cell and sets the new player_id while shifting the old one to the previous_player_id
  iex> CellGrower.check_for_regeneration(%GridCell{live: false, empty: false, player_id: 1, index: 0, killed_by: 2}, %FungusToast.Games.Player{regeneration_chance: 100, id: 2})
  %FungusToast.Games.GridCell{
    empty: false,
    index: 0,
    live: true,
    out_of_grid: false,
    player_id: 2,
    previous_player_id: 1,
    killed_by: nil
  }

  #it returns nil if the regeneration chance didn't hit
  iex> CellGrower.check_for_regeneration(%GridCell{}, %FungusToast.Games.Player{regeneration_chance: 0, id: 2})
  nil

  """
  def check_for_regeneration(grid_cell, player) do
    if(Random.random_chance_hit(player.regeneration_chance)) do
      %{grid_cell | live: true, previous_player_id: grid_cell.player_id, player_id: player.id, killed_by: nil}
    end
  end


  @doc ~S"""
  Returns %{} if the cell does not die, otherwise returns a killed %GridCell{}

  ## Examples

  #it returns %{} if the cell doesn't die
  iex>CellGrower.check_for_cell_death(%FungusToast.Games.GridCell{}, %{top_cell: %FungusToast.Games.GridCell{}}, %FungusToast.Games.Player{apoptosis_chance: 0.0})
  %{}

  """
  def check_for_cell_death(grid_cell, surrounding_cells, player) do
    if(dies_from_starvation(surrounding_cells) or dies_from_apoptosis(player)) do
      %{ grid_cell.index => %{grid_cell | live: false} }
    else
      %{}
    end
  end

  @doc ~S"""
  Returns true if the cell dies from starvation (when surrounding by live cells), false otherwise

  ## Examples

  #it dies if the cell is surrounded and the starvation chance hits
  iex> surrounding_cells =
  ...>%{
  ...>  bottom_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  top_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  }
  ...>}
  ...>CellGrower.dies_from_starvation(surrounding_cells, 100)
  true

  #it does not die if the starvation chance misses
  iex> surrounding_cells =
  ...>%{
  ...>  bottom_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  top_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  }
  ...>}
  ...>CellGrower.dies_from_starvation(surrounding_cells, 0)
  false

  #it does not die if not all of the surrounding cells are alive
  iex> surrounding_cells =
  ...>%{
  ...>  bottom_cell: %FungusToast.Games.GridCell{
  ...>    live: false
  ...>  },
  ...>  bottom_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  bottom_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  left_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  right_cell: %FungusToast.Games.GridCell{
  ...>    live: true
  ...>  },
  ...>  top_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_left_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  },
  ...>  top_right_cell: %FungusToast.Games.GridCell{
  ...>    live: true,
  ...>  }
  ...>}
  ...>CellGrower.dies_from_starvation(surrounding_cells, 100)
  false

  """
  def dies_from_starvation(surrounding_cells, starvation_chance \\ @starvation_death_chance) do
    Enum.all?(surrounding_cells, fn {_, v} -> v.live end) and Random.random_chance_hit(starvation_chance)
  end

  @doc ~S"""
  Returns true if the cell dies from apoptosis, false otherwise

  ## Examples

  #it dies if the apoptosis chance hits
  iex> CellGrower.dies_from_apoptosis(%FungusToast.Games.Player{apoptosis_chance: 100.0, live_cells: 100})
  true

  #it does not die if the apoptosis chance misses
  iex> CellGrower.dies_from_apoptosis(%FungusToast.Games.Player{apoptosis_chance: 0.0})
  false

  #it does not die if the player has less than the minimum number of live cells
  iex> CellGrower.dies_from_apoptosis(%FungusToast.Games.Player{apoptosis_chance: 100.0, live_cells: FungusToast.Games.CellGrower.minimum_live_cells_for_apoptosis() - 1})
  false

  """
  def dies_from_apoptosis(player) do
    if(player.live_cells < @minimum_live_cells_for_apoptosis) do
      false
    else
      Random.random_chance_hit(player.apoptosis_chance)
    end
  end

  @doc ~S"""
  Returns an out of grid cell

  ## Examples

  iex> CellGrower.make_out_of_grid_cell()
  %FungusToast.Games.GridCell{
    empty: false,
    index: nil,
    live: false,
    out_of_grid: true,
    player_id: nil,
    previous_player_id: nil
  }

  """
  def make_out_of_grid_cell() do
    %GridCell{live: false, empty: false, out_of_grid: true}
  end

  @doc ~S"""
  Returns an empty cell at the specified cell_index

  ## Examples

  iex> CellGrower.make_empty_grid_cell(1)
  %FungusToast.Games.GridCell{
    empty: true,
    index: 1,
    live: false,
    out_of_grid: false,
    player_id: nil,
    previous_player_id: nil
  }

  """
  def make_empty_grid_cell(cell_index) do
    %GridCell{index: cell_index, live: false, empty: true, out_of_grid: false}
  end
end
