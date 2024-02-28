defmodule XandoTest do
  use ExUnit.Case
  doctest Xando

  alias Xando.Game

  setup_all do
    {:ok, grid_size: 4}
  end

  test "can initialise game", state do
    game = Game.init_game(state[:grid_size])

    assert game.complete == false
    assert game.remaining_moves == state[:grid_size] * state[:grid_size]
    assert Map.keys(game.board) == Enum.map(
      0..state[:grid_size] - 1, fn x ->
        Enum.map(
          0..state[:grid_size] - 1, fn y ->
            {x, y}
          end)
      end)
      |> List.flatten
  end

  test "can make a moves" do
    game = Game.init_game(3)
    game = Game.play("X", {0, 0}, game)
    game = Game.play("O", {1, 1}, game)
    game = Game.play("X", {2, 2}, game)
    boad_str = Map.values(game.board) |> List.to_string

    assert game.complete == false
    assert game.last_move == "X"
    assert game.next_move == "O"
    assert game.comment == "next move O"
    assert boad_str == "X   O   X"
  end

end
