alias IslandsEngine.{Coordinate, Guesses, Island, Board}

guesses = Guesses.new

{:ok, coordinate1} = Coordinate.new(1, 1)

{:ok, coordinate2} = Coordinate.new(2, 2)

guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate1))
