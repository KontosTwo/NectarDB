defmodule NectarNode.CommunicatorTest do
  use ExUnit.Case, async: false

  alias NectarNode.Communicator
  alias NectarNode.Server
  alias NectarNode.Oplog

  setup do
    start_supervised!(Communicator)
    start_supervised!(Server)
    start_supervised!(Oplog)
    Node.start(:test@localhost,:shortnames)
    Node.connect(:test1@localhost)
    Communicator.add_node("test1@localhost")    
    :ok
  end

  describe "communicate an operation" do
    test "to one other node" do
      """
      Communicator.communicate_op({1,{:read,1}})

      sent_ops = Oplog.get_logs()
      assert [{1,{:read,1}}] == sent_ops
      """
    end

    test "to three other nodes" do

    end
  end
end
