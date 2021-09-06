alias IslandsEngine.{Coordinate, Guesses, Island, Board, Game}

board = Board.new()

{:ok, square_coordinate} = Coordinate.new(1, 1)
{:ok, square} = Island.new(:square, square_coordinate)
board = Board.position_island(board, :square, square)

{:ok, new_dot_coordinate} = Coordinate.new(3, 3)
{:ok, dot} = Island.new(:dot, new_dot_coordinate)
board = Board.position_island(board, :dot, dot)
