defmodule XandoTest do
  use ExUnit.Case
  doctest Xando

  alias Xando.Game

  setup_all do
    {:ok, grid_size: 4, game: Game.init_game(3)}
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

  test "can make a moves", state do
    game = state[:game]
    game = Game.play("X", {0, 0}, game)
      |> (&Game.play("O", {1, 1}, &1)).()
      |> (&Game.play("X", {2, 2}, &1)).()
    boad_str = Map.values(game.board) |> List.to_string

    assert game.complete == false
    assert game.last_move == "X"
    assert game.next_move == "O"
    assert game.comment == "next move O"
    assert boad_str == "X   O   X"
  end

  test "cannot make opponent move on occupied square", state do
    game = state[:game]
    game = Game.play("X", {0, 0}, game)
      |> (&Game.play("O", {0, 0}, &1)).()
    {err, _} = game.comment

    assert Map.get(game.board, {0, 0}) == "X"
    assert err == :error
  end

  # Completion scenarios
  test "won by rows #1", state do
    game = state[:game]
    game = Game.play("X", {0, 0}, game)
      |> (&Game.play("O", {1, 1}, &1)).()
      |> (&Game.play("X", {0, 1}, &1)).()
      |> (&Game.play("O", {2, 2}, &1)).()
      |> (&Game.play("X", {0, 2}, &1)).()

    assert game.complete == true
    assert game.comment == "X wins by row"
  end

  test "won by columns #1", state do
    game = state[:game]
    game = Game.play("X", {0, 0}, game)
      |> (&Game.play("O", {1, 1}, &1)).()
      |> (&Game.play("X", {1, 0}, &1)).()
      |> (&Game.play("O", {2, 2}, &1)).()
      |> (&Game.play("X", {2, 0}, &1)).()

    assert game.complete == true
    assert game.comment == "X wins by column"
  end

end
