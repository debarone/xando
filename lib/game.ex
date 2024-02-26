defmodule Xando.Game do
  alias TableRex.Table

  def init_game() do
    %{
      result: "",
      last_move: :nil,
      next_move: :nil,
      comment: {:ok, ""},
      complete: false,
      board: {
        "_", "_", "_",
        "_", "_", "_",
        "_", "_", "_"
      }
    }
  end

  def play(player, move, game) do
    index = translate_move(move)

    if not game.complete and can_play?(player, game, index) do
      new_game = Map.put(game, :board, put_elem(game.board, index, player))
      |> Map.put(:last_move, player)
      |> Map.put(:next_move, toggle_player(player))

      if victory?(player, new_game) do
        Map.put(game, :comment, {:ok, ~s"Game complete, #{player} wins!"})
        |> Map.put(:result, ~s"#{player} wins!")
        |> Map.put(:complete, true)
      else
        Map.put(new_game, :comment, {:ok, "continue..."})
      end
    else
      Map.put(game, :comment, {:error, "Invalid move"})
    end
  end

  def victory?(player, game) do
    col = ~r/(#{player}[^#{player}]{2}#{player}[^#{player}]{2}#{player})/
    row = ~r/([#{player}]{3}+)/
    l_diagonal = ~r/(#{player}[^#{player}]{3}#{player}[^#{player}]{3}#{player})/
    r_diagonal = ~r/(#{player}[^#{player}]{1}#{player}[^#{player}]{1}#{player})/

    board_str = Tuple.to_list(game.board) |> List.to_string
    Enum.any?([col, row, l_diagonal, r_diagonal], fn x -> Regex.match?(x, board_str) end)
  end

  def toggle_player(player) do
    case player do
      "X" -> "O"
      "O" -> "X"
      _ -> player
    end 
  end

  def can_play?(player, game, index) do
    case {elem(game.board, index), game.next_move == :nil or player == game.next_move}  do
      {"_", true} -> true
      _ -> false
    end
  end

  def translate_move(move) do
    case move do
      "a1" -> 0
       "b1" -> 1
       "c1" -> 2
       "a2" -> 3
       "b2" -> 4
       "c2" -> 5
       "a3" -> 6
       "b3" -> 7
       _ -> 8 # Assume that anything else is the last element
    end
  end

  def print_board(board) do
    Tuple.to_list(board)
    |> Enum.chunk_every(3)
    |> Table.new([])
    |> Table.put_column_meta(:all, align: :center)
    |> Table.render!(horizontal_style: :all)
    |> IO.puts
  end

end
