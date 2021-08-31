defmodule IslandsEngineTest do
  use ExUnit.Case
  doctest IslandsEngine
  alias IslandsEngine.Rules

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
end
