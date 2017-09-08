ExUnit.start()
Code.require_file "game.exs", __DIR__

defmodule BowlingTest do
  use ExUnit.Case

  setup do
    [game: Bowling.new_game]
  end

  test "new game has no rolls", fixture do
    assert fixture.game.rolls == []
  end

  test "new game has score of 0", fixture do
    assert fixture.game.score == 0
  end

  test "single roll is added to game rolls", fixture do
    game = Bowling.roll(fixture.game, 1)
    assert game.rolls == [1]
  end

  test "multiple rolls are added to game rolls", fixture do
    game = Enum.reduce([1,2], fixture.game, fn(p, g) -> Bowling.roll(g, p) end)
    assert game.rolls == [1,2]
  end

  test "multiple rolls score", fixture do
    result = Enum.reduce(List.duplicate(1, 20), fixture.game, fn(pinfall, game) ->
      Bowling.roll(game, pinfall)
    end)
    assert result.score == 20
  end

  test "multiple rolls with strike in last frame", fixture do
    rolls = List.duplicate(1, 18) ++ [10,3,3]
    game = Enum.reduce(rolls, fixture.game, fn(p, g) -> Bowling.roll(g, p) end)
    assert game.score == 34
  end

  test "incomplete open frame scores 0", fixture do
    game = Bowling.roll(fixture.game, 1)
    assert game.score == 0
  end

  test "complete open frame scores correctly", fixture do
    game = Bowling.roll(fixture.game, 1) |> Bowling.roll(2)
    assert game.score == 3
  end

  test "no rolls" do
    assert Bowling.score([]) == 0
  end

  test "complete open frame" do
    assert Bowling.score([1,1]) == 2
  end

  test "multiple complete open frames" do
    assert Bowling.score([1,1,1,1,1,1]) == 6
  end

  test "incomplete frame" do
    assert Bowling.score([1]) == 0
  end

  test "complete open frames with incomplete frame" do
    assert Bowling.score([1,1,1,1,1]) == 4
  end

  test "complete strike" do
    assert Bowling.score(List.duplicate(1, 18) ++ [10,3,3]) == 34
  end

  test "incomplete strike with no bonus rolls" do
    assert Bowling.score([10]) == 0
  end

  test "complete strike in first frame" do
    assert Bowling.score([10,3,3]) == 16
  end

  test "complete strike in second frame" do
    assert Bowling.score([1,1,10,3,3]) == 18
  end

  test "incomplete strike with one bonus roll" do
    assert Bowling.score([10,1]) == 0
  end

  test "complete spare" do
    assert Bowling.score([5,5,1]) == 11
  end

  test "incomplete spare" do
    assert Bowling.score([5,5]) == 0
  end

  test "spare with complete open frame" do
    assert Bowling.score([5,5,1,1]) == 13
  end

  test "strike with complete spare" do
    assert Bowling.score([10,2,8,5]) == 35
  end

  test "strike with incomplete spare" do
    assert Bowling.score([10,2,8]) == 20
  end

  test "all gutter balls" do
    rolls = List.duplicate(0, 20)
    assert Bowling.score(rolls) == 0
  end

  test "all spares" do
    rolls = List.duplicate(5, 21)
    assert Bowling.score(rolls) == 150
  end

  test "perfect game" do
    rolls = List.duplicate(10, 12)
    assert Bowling.score(rolls) == 300
  end

  test "complete spare followed by complete open frame" do
    assert Bowling.score([3,7,4,1]) == 19
  end

  test "complete spare followed by strike with no bonus rolls" do
    assert Bowling.score([3,7,10]) == 20
  end

  test "complete spare followed by strike with one bonus roll" do
    assert Bowling.score([3,7,10,1]) == 20
  end

  test "almost perfect" do
    rolls = List.duplicate(10, 10) ++ [9,0]
    assert Bowling.score(rolls) == 288
  end

  test "nine strikes, last frame gutters" do
    rolls = List.duplicate(10, 9) ++ [0,0]
    assert Bowling.score(rolls) == 240
  end

  test "last frame spare" do
    rolls = List.duplicate(0, 18) ++ [5,5,1]
    assert Bowling.score(rolls) == 11
  end

  test "last frame spare, bonus of 10" do
    rolls = List.duplicate(0, 18) ++ [5,5,10]
    assert Bowling.score(rolls) == 20
  end

  test "all spares but last" do
    rolls = List.duplicate(5, 18) ++ [1,1]
    assert Bowling.score(rolls) == 133
  end
end
