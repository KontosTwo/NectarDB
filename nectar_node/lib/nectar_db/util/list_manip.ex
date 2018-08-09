defmodule NectarDb.ListManip do
  def reverse([]) do
    []
  end

  def reverse([a]) do
    [a]
  end

  def reverse([h | t]) do
    reverse([h | t],[])
  end

  defp reverse([h | t],acc) do
    reverse(t,[h | acc])
  end

  defp reverse([],acc) do
    acc
  end
end
