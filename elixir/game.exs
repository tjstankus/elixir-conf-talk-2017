defmodule Bowling do
  defstruct rolls: [], score: 0

  def new_game do
    %Bowling{}
  end

  def roll(game = %Bowling{}, pinfall) do
    rolls = append_pinfall(game.rolls, pinfall)
    %{ game | rolls: rolls, score: score(rolls) }
  end

  # strike in last frame
  def score([10, bonus1, bonus2 | _tail = []]) do
    10 + bonus1 + bonus2
  end

  # strike
  def score([10, bonus1, bonus2 | tail]) do
    10 + bonus1 + bonus2 + score([bonus1, bonus2 | tail])
  end

  # spare
  def score([roll1, roll2, bonus | tail]) when roll1 + roll2 == 10 do
                                                       10 + bonus + score([bonus | tail])
  end

  # open frame
  def score([roll1, roll2 | tail]) when roll1 + roll2 < 10 do
                                                roll1 + roll2 + score(tail)
  end

  def score([_|_]), do: 0 # incomplete frame
  def score([]), do: 0 # no rolls

  defp append_pinfall(rolls, pinfall) do
    [ pinfall | Enum.reverse(rolls) ]
    |> Enum.reverse
  end
end
