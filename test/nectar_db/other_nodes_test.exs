defmodule NectarDb.OtherNodesTest do
  use ExUnit.Case, async: false

  alias NectarDb.OtherNodes

  setup do
    {:ok, _bucket} = start_supervised({OtherNodes, []})
    :ok
  end

  describe "adding and retrieving nodes from OtherNodes" do
    test "succeeds for addition" do
      OtherNodes.add_node("a@a")
      assert ["a@a"] == OtherNodes.get_nodes()

      :ok = stop_supervised(OtherNodes)
    end

    test "succeeds for multiple additions" do
      OtherNodes.add_node("a@a")
      OtherNodes.add_node("a@b")
      OtherNodes.add_node("a@c")
      assert ["a@c", "a@b", "a@a"] == OtherNodes.get_nodes()
      stop_supervised(OtherNodes)
    end
  end
end
