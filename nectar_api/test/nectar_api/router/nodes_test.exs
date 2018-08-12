defmodule NectarAPI.Router.NodesTest do
  use ExUnit.Case, async: true

  alias NectarAPI.Router.Nodes

  setup do
    start_supervised!(Nodes)
    :ok
  end

  describe "adding and getting nodes" do
    test "saves node" do
      Nodes.add_node("a@com")
      assert [:a@com] == Nodes.all_nodes()
    end

    test "saves multiple nodes" do
      Nodes.add_node("a@com")
      Nodes.add_node("b@com")
      Nodes.add_node("c@com")      
      assert [:a@com,:b@com,:c@com] == Nodes.all_nodes()
    end

    test "no nodes" do
      assert [] == Nodes.all_nodes()
    end
  end

  describe "round robin" do
    test "no nodes" do
      assert nil == Nodes.next_node()
    end

    test "one node" do
      Nodes.add_node("a@com")
      assert :a@com == Nodes.next_node()
    end

    test "multiple nodes" do
      Nodes.add_node("a@com")
      Nodes.add_node("b@com")
      Nodes.add_node("c@com")      
      assert :a@com == Nodes.next_node()
      assert :b@com == Nodes.next_node()
      assert :c@com == Nodes.next_node()
      assert :a@com == Nodes.next_node()
    end
  end
end