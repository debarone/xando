defmodule Xando.Game do
  alias TableRex.Table

  def init_game(grid_size) do
    %{
      result: "",
      last_move: :nil,
      next_move: :nil,
      comment: {:ok, ""},
      complete: false,
      grid_size: grid_size,
      remaining_moves: grid_size * grid_size,
      board: init_game_board(grid_size)
    }
  end

  defp init_game_board(grid_size) do
    for row <- 0..grid_size - 1,
      col <- 0..grid_size - 1 do
        {row, col}
    end
    |> Map.from_keys(" ")
  end

  def play(player, move, game) do
     if not game.complete and can_play?(player, game, move) do
      new_game = Map.put(game, :board, Map.put(game.board, move, player))
      |> Map.put(:last_move, player)
      |> Map.put(:next_move, toggle_player(player))
      |> Map.put(:remaining_moves, game.remaining_moves - 1)

      if victory?(player, new_game) do
        Map.put(new_game, :comment, {:ok, ~s"Game complete, #{player} wins!"})
        |> Map.put(:result, ~s"#{player} wins!")
        |> Map.put(:complete, true)
      else
        if game.remaining_moves <= 0 do
          Map.put(new_game, :comment, {:ok, "Stalemate, no one wins!"})
          |> Map.put(:result, "Stalemate")
          |> Map.put(:complete, true)
        else
          Map.put(new_game, :comment, {:ok, ~s"Next move #{toggle_player(player)}"})
        end
      end
    else
      Map.put(game, :comment, {:error, "Invalid move"})
    end
  end
  
  def victory?(player, game) do
    check_victory_columns?(false, player, game)
    |> check_victory_rows?(game.board, game.grid_size)
    |> check_victory_right_diagonal?(player, game)
    |> check_victory_left_diagonal?(player, game)
  end
  
  defp check_victory_columns?(checked, player, game) do
    if not checked do
      col_regex = ~r/(#{player}[#{player}#{toggle_player(player)}\s]{#{game.grid_size - 1}}){#{game.grid_size - 1}}#{player}/
      board_str = Map.values(game.board) |> List.to_string
      Regex.match?(col_regex, board_str)
    else
      checked
    end
  end

  defp check_victory_rows?(checked, board, grid_size) do
    if not checked do
      Enum.chunk_every(Map.values(board), grid_size)
      |> Enum.filter(fn x -> MapSet.new(x) != MapSet.new([" "]) end)
      |> Enum.any?(fn x -> MapSet.size(MapSet.new(x)) == 1 end)
    else
      checked
    end
  end

  defp check_victory_right_diagonal?(checked, player, game) do
    if not checked do
      r_diag = Enum.filter(Map.keys(game.board), fn {x, y} ->
        x == y and
        Map.get(game.board, x) != " "
      end)
      |> Enum.map(fn x -> Map.get(game.board, x) end)
      |> List.to_string
      Regex.match?(~r/^[#{player}]{game.grid_size}$/, r_diag)
    else
      checked
    end
  end

  defp check_victory_left_diagonal?(checked, player, game) do
    if not checked do
      l_diag = Enum.filter(Map.keys(game.board), fn {x, y} ->
        y == 1 and 0 < x and x < game.grid_size - 1
      end)
      |> Kernel.++([{0, game.grid_size - 1}, {game.grid_size - 1, 0}])  # Add corner coordinates
      |> Enum.filter(fn x -> Map.get(game.board, x) != " " end)
      |> Enum.map(fn x -> Map.get(game.board, x) end)
      |> List.to_string
      Regex.match?(~r/^[#{player}]{game.grid_size}$/, l_diag)
    else
      checked
    end
  end

  def toggle_player(player) do
    case player do
      "X" -> "O"
      "O" -> "X"
      _ -> player
    end 
  end

  def can_play?(player, game, move) do
    case {
      Map.get(game.board, move),
      (game.next_move == :nil or player == game.next_move)
    }  do
      {" ", true} -> true
      _ -> false
    end
  end

  def print_board(board) do
    Map.values(board)
    |> Enum.chunk_every(3)
    |> Table.new([])
    |> Table.put_column_meta(:all, align: :center)
    |> Table.render!(horizontal_style: :all)
    |> IO.puts
  end

end
