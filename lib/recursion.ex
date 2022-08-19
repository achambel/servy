defmodule Recursion do
  def loopy([head | tail]) do
    IO.puts("Head: #{head} Tail: #{inspect(tail)}")
    loopy(tail)
  end

  def loopy([]), do: IO.puts("Done!")
end

Recursion.loopy([1, 2, 3, 4, 5])

# It's gonna print
# Head: 1 Tail: [2, 3, 4, 5]
# Head: 2 Tail: [3, 4, 5]
# Head: 3 Tail: [4, 5]
# Head: 4 Tail: [5]
# Head: 5 Tail: []
# Done!
