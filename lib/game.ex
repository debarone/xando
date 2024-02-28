defmodule Xando.Game do
  alias TableRex.Table

  def init_game(grid_size) do
    %{
      last_move: :nil,
      next_move: :nil,
      comment: {:ok, ""},
      complete: false,
      grid_size: grid_size,
      remaining_moves: grid_size * grid_size,
      board: init_game_board(grid_size)
    }
  end

  def play(player, move, game) do
     if not game.complete and can_play?(player, game, move) do
      new_game = Map.put(game, :board, Map.put(game.board, move, player))
      |> Map.put(:last_move, player)
      |> Map.put(:next_move, toggle_player(player))
      |> Map.put(:remaining_moves, game.remaining_moves - 1)

      case victory?(player, new_game) do
        {:ok, true, comment} -> true
          Map.put(new_game, :comment, comment)
          |> Map.put(:complete, true)
        _ ->
          Map.put(new_game, :comment, ~s"next move #{toggle_player(player)}")
      end
    else
      Map.put(game, :comment, {:error, "Invalid move"})
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

  def victory?(player, game) do
    check_stalemate?(game)
    |> check_victory_columns?(player, game)
    |> check_victory_rows?(player, game)
    |> check_victory_right_diagonal?(player, game)
    |> check_victory_left_diagonal?(player, game)
  end
 
  #
  # Private Functions
  #

  defp init_game_board(grid_size) do
    for row <- 0..grid_size - 1,
      col <- 0..grid_size - 1 do
        {row, col}
    end
    |> Map.from_keys(" ")
  end

  defp check_stalemate?(game) do
    stalemate = game.remaining_moves == 0
    {:ok, stalemate, if stalemate do
        "stalemate"
      else
        ""
    end}
  end

  defp check_victory_columns?(checked, player, game) do
    case checked do
      {:ok, false, _} -> 
        match_rgx = Regex.match?(
          ~r/(#{player}[#{player}#{toggle_player(player)}\s]{#{game.grid_size - 1}}){#{game.grid_size - 1}}#{player}/,
          Map.values(game.board) |> List.to_string
        )

        {:ok, match_rgx, if match_rgx do
            ~s"#{player} wins by column"
        else
            ""
        end}
      _ -> checked
    end
  end

  defp check_victory_rows?(checked, player, game) do
    case checked do
      {:ok, false, _} ->
        row_victory = Enum.chunk_every(Map.values(game.board), game.grid_size)
          |> Enum.filter(fn x -> MapSet.new(x) != MapSet.new([" "]) end)
          |> Enum.any?(fn x -> MapSet.size(MapSet.new(x)) == 1 end)
        
        {:ok, row_victory, if row_victory do
            ~s"#{player} wins by row"
          else
            ""
        end}
      _ -> checked
    end
  end

  defp check_victory_right_diagonal?(checked, player, game) do
    case checked do
      {:ok, false, _} ->
        r_diag = Enum.filter(Map.keys(game.board), fn {x, y} ->
            x == y and
            Map.get(game.board, x) != " "
          end)
          |> Enum.map(fn x -> Map.get(game.board, x) end)
          |> List.to_string
        r_diag_victory = Regex.match?(~r/^[#{player}]{game.grid_size}$/, r_diag)

        {:ok, r_diag_victory, if r_diag_victory do
            ~s"#{player} wins by right diagonal"
          else
            ""
        end}
      _ -> checked
    end
  end

  defp check_victory_left_diagonal?(checked, player, game) do
    case checked do
      {:ok, false, _} ->
        l_diag = Enum.filter(Map.keys(game.board), fn {x, y} ->
          y == 1 and 0 < x and x < game.grid_size - 1
        end)
        |> Kernel.++([{0, game.grid_size - 1}, {game.grid_size - 1, 0}])  # Add corner coordinates
        |> Enum.filter(fn x -> Map.get(game.board, x) != " " end)
        |> Enum.map(fn x -> Map.get(game.board, x) end)
        |> List.to_string
        l_diag_victory = Regex.match?(~r/^[#{player}]{game.grid_size}$/, l_diag)

        {:ok, l_diag_victory, if l_diag_victory do
            ~s"#{player} wins by left diagonal"
          else
            ""
        end}
      _ -> checked
    end
  end

end
