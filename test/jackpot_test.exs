defmodule JackpotTest do
  use ExUnit.Case
  doctest Jackpot

  alias Jackpot.AgentMin
  alias Jackpot.AgentMax
  alias Jackpot.AgentFirst
  alias Jackpot.AgentLast
  alias Jackpot.AgentHiLo
  alias Jackpot.AgentHiLo2
  alias Jackpot.Board
  alias Jackpot.Dice
  alias Jackpot.Game
  alias Jackpot.Graph

  @agents [AgentMin, AgentMax, AgentFirst, AgentLast, AgentHiLo, AgentHiLo2]

  @new_board %{
    1 => false,
    2 => false,
    3 => false,
    4 => false,
    5 => false,
    6 => false,
    7 => false,
    8 => false,
    9 => false
  }

  test "board" do
    board = Board.new()

    assert board == @new_board
    assert not Board.win?(board)
    assert Board.index(board) == 0

    assert Enum.map(1..9, fn c -> assert not Board.cell?(board, c) end)

    board = Board.flip(board, 1)
    assert Board.cell?(board, 1)
    assert Board.index(board) == 1

    board = Board.flip(board, 4)
    assert Board.cell?(board, 4)
    assert Board.index(board) == 9
    assert_raise RuntimeError, "Cell 4 is already flipped", fn -> Board.flip(board, 4) end

    assert not Board.win?(board)

    board = Enum.reduce(1..9, @new_board, fn i, board -> Board.flip(board, i) end)
    assert Board.win?(board)
    assert Board.index(board) == 511

    for i <- 0..511 do
      assert i |> Board.new() |> Board.index() == i
    end

    boards = Board.all_boards()
    assert boards |> Map.keys() |> Enum.sort() == Enum.to_list(0..511)
    Enum.each(boards, fn {i, board} -> assert Board.index(board) == i end)
  end

  test "dice" do
    {d1, d2} = roll = Dice.roll()
    assert d1 in 1..6
    assert d2 in 1..6

    cells = Dice.cells(roll)
    assert d1 in cells
    assert d2 in cells

    if d1 + d2 <= 9 do
      assert length(cells) == 3 and (d1 + d2) in cells
    else
      assert length(cells) == 2
    end

    all_rolls = Dice.all_rolls()
    assert length(all_rolls) == 36

    all_cells = Dice.all_cells()
    assert length(all_cells) == 36
    ncell = Dice.all_cells() |> Enum.group_by(&length(&1))

    # just those rolls that add to more than 9
    # {5,5} {6,4} {4,6} {5,6} {6,5} {6,6}
    assert ncell |> Map.fetch!(2) |> length() == 6
    # the rest ...
    assert ncell |> Map.fetch!(3) |> length() == 30

    nchoice =
      Dice.all_cells()
      |> Enum.map(&Enum.uniq(&1))
      |> Enum.group_by(&length(&1))

    # just those doubles that add to more than 9:
    # {5,5} {6,6} 
    assert nchoice |> Map.fetch!(1) |> length() == 2
    # distinct pairs that add to more than 9 and lower doubles:
    # {6,4} {4,6} {5,6} {6,5}   {1,1} {2,2} {3,3} {4,4}  
    assert nchoice |> Map.fetch!(2) |> length() == 8
    assert nchoice |> Map.fetch!(3) |> length() == 26
  end

  for agent <- [AgentHiLo, AgentHiLo2] do
    test "game #{agent}" do
      agent = unquote(agent)

      for _i <- 1..100 do
        case Game.play(agent) do
          {:win, board, moves} ->
            assert Board.win?(board)
            assert moves |> Enum.map(&elem(&1, 1)) |> Enum.sort() == Enum.to_list(1..9)

          {:lose, board, moves} ->
            assert not Board.win?(board)
            assert [{_roll, :no_move} | sevom] = Enum.reverse(moves)
            assert length(sevom) < 9

            assert Enum.all?(sevom, fn {_roll, i} ->
                     is_integer(i) and 1 <= i and i <= 9
                   end)
        end
      end
    end
  end

  test "statistics" do
    n = 100_000
    IO.puts("")
    IO.puts("MONTE CARLO (#{n})")

    for agent <- @agents do
      stats = Game.monte_carlo(agent, n)
      label = String.pad_trailing("#{agent} ", 29)
      IO.inspect(stats.win, label: label)
    end
  end

  test "graph" do
    IO.puts("")
    IO.puts("CALCULATED")

    for agent <- @agents do
      stats = Graph.calculate_outcomes(agent)
      label = String.pad_trailing("#{agent} ", 29)
      IO.inspect(stats.win, label: label)
    end
  end
end
