defmodule IslandsEngineTest do
  use ExUnit.Case
  doctest IslandsEngine
  alias IslandsEngine.{Rules, Game}

  test "greets the world" do
    assert IslandsEngine.hello() == :world
  end

  test "Runs a full state transition (chapter 3)" do
    rules = Rules.new()
    assert rules.state == :initialized

    {:ok, rules} = Rules.check(rules, :add_player)
    assert rules.state == :players_set

    {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
    assert rules.state == :players_set

    {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
    assert rules.state == :players_set

    {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert rules.state == :players_set

    result = Rules.check(rules, {:position_islands, :player1})
    assert result == :error

    {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
    assert rules.state == :player1_turn

    result = Rules.check(rules, {:guess_coordinate, :player2})
    assert result == :error

    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
    assert rules.state == :player2_turn

    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})
    assert rules.state == :player1_turn

    {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert rules.state == :player1_turn

    {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert rules.state == :game_over
  end

  test "Game gen server" do
    {:ok, game} = Game.start_link("Miles")

    # can't guess yet
    result = Game.guess_coordinate(game, :player1, 1, 1)
    assert result == :error

    Game.add_player(game, "Trane")

    Game.position_island(game, :player1, :atoll, 1, 1)
    Game.position_island(game, :player1, :dot, 1, 4)
    Game.position_island(game, :player1, :l_shape, 1, 5)
    Game.position_island(game, :player1, :s_shape, 5, 1)
    Game.position_island(game, :player1, :square, 5, 5)

    Game.position_island(game, :player2, :atoll, 1, 1)
    Game.position_island(game, :player2, :dot, 1, 4)
    Game.position_island(game, :player2, :l_shape, 1, 5)
    Game.position_island(game, :player2, :s_shape, 5, 1)
    Game.position_island(game, :player2, :square, 5, 5)

    Game.set_islands(game, :player1)
    Game.set_islands(game, :player2)

    state_data = :sys.get_state(game)
    assert state_data.rules.state == :player1_turn

    result = Game.guess_coordinate(game, :player1, 5, 5)
    assert result == {:hit, :none, :no_win}

    # can't go twice in a row
    result = Game.guess_coordinate(game, :player1, 8, 8)
    assert result == :error

    result = Game.guess_coordinate(game, :player2, 8, 8)
    assert result == {:miss, :none, :no_win}

    # atoll
    Game.guess_coordinate(game, :player1, 1, 1)
    Game.guess_coordinate(game, :player2, 1, 1)
    Game.guess_coordinate(game, :player1, 3, 1)
    Game.guess_coordinate(game, :player2, 1, 1)
    Game.guess_coordinate(game, :player1, 1, 2)
    Game.guess_coordinate(game, :player2, 1, 1)
    Game.guess_coordinate(game, :player1, 2, 2)
    Game.guess_coordinate(game, :player2, 2, 3)
    Game.guess_coordinate(game, :player1, 3, 2)
    Game.guess_coordinate(game, :player2, 1, 1)

    # dot
    Game.guess_coordinate(game, :player1, 1, 4)
    Game.guess_coordinate(game, :player2, 1, 1)

    # l
    Game.guess_coordinate(game, :player1, 1, 5)
    Game.guess_coordinate(game, :player2, 1, 1)
    Game.guess_coordinate(game, :player1, 2, 5)
    Game.guess_coordinate(game, :player2, 1, 1)
    Game.guess_coordinate(game, :player1, 3, 5)
    Game.guess_coordinate(game, :player2, 1, 1)
    Game.guess_coordinate(game, :player1, 3, 6)
    Game.guess_coordinate(game, :player2, 1, 1)

    # s
    Game.guess_coordinate(game, :player1, 6, 1)
    Game.guess_coordinate(game, :player2, 5, 2)
    Game.guess_coordinate(game, :player1, 5, 2)
    Game.guess_coordinate(game, :player2, 1, 1)
    Game.guess_coordinate(game, :player1, 6, 2)
    Game.guess_coordinate(game, :player2, 1, 1)
    result = Game.guess_coordinate(game, :player1, 5, 3)
    assert {:hit, :s_shape, :no_win} == result

    Game.guess_coordinate(game, :player2, 1, 1)

    # square
    Game.guess_coordinate(game, :player1, 5, 5)
    Game.guess_coordinate(game, :player2, 1, 1)
    Game.guess_coordinate(game, :player1, 6, 5)
    Game.guess_coordinate(game, :player2, 1, 1)
    Game.guess_coordinate(game, :player1, 5, 6)
    Game.guess_coordinate(game, :player2, 1, 1)

    result = Game.guess_coordinate(game, :player1, 6, 6)

    assert {:hit, :square, :win} == result
    # state_data = :sys.get_state(game)
    # IO.inspect(state_data)
  end
end
