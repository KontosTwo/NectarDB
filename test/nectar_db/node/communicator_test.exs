defmodule NectarDb.CommunicatorTest do
  use ExUnit.Case, async: false

  alias NectarDb.Communicator
  alias NectarDb.Server
  alias NectarDb.Oplog

  setup do
    start_supervised!(Communicator)
    start_supervised!(Server)
    start_supervised!(Oplog)

    :ok
  end

  describe "communicate an operation" do
    test "to one other node" do
      Node.start(:a@localhost,:shortnames)
      Communicator.add_node("a@localhost")
      require IEx; IEx.pry

      Communicator.communicate_op({1,{:read,1}})

      sent_ops = :rpc.call(:a@localhost,Oplog,:get_logs,[])
      assert [{1,{:read,1}}] == sent_ops
    end

    test "to three other nodes" do
      Node.start(:a@localhost,:shortnames)
      Node.start(:b@localhost,:shortnames)
      Node.start(:c@localhost,:shortnames)

    end
  end
end
