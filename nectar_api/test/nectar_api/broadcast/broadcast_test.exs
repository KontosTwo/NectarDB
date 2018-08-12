defmodule NectarAPI.Broadcast.BroadcastTest do
  use ExUnit.Case, async: false

  alias NectarAPI.Broadcast.Generator
  alias NectarAPI.Broadcast.Supervisor  
  alias NectarAPI.Broadcast.RPC

  import Mock

  setup do
    start_supervised!(Generator)
    start_supervised!(Supervisor)
    :ok
  end

  describe "broadcast operations" do
    test "broadcast one operation" do
      with_mock(RPC, call: fn _node, _module, _fun, _args -> nil end) do
        Generator.broadcast(:a@com,{1,{:write,1,2}})
        Process.sleep(100)
        assert_called(RPC.call(:a@com,NectarNode.Server,:receive_oplog_entry,[{1,{:write,1,2}}]))
      end
    end

    test "broadcast multiple operation" do
      with_mock(RPC, call: fn _node, _module, _fun, _args -> nil end) do
        Generator.broadcast(:a@com,{1,{:write,1,2}})
        Generator.broadcast(:b@com,{1,{:write,1,2}})
        Generator.broadcast(:c@com,{1,{:write,1,2}})
        
        Process.sleep(100)
        assert_called(RPC.call(:a@com,NectarNode.Server,:receive_oplog_entry,[{1,{:write,1,2}}]))
        assert_called(RPC.call(:b@com,NectarNode.Server,:receive_oplog_entry,[{1,{:write,1,2}}]))
        assert_called(RPC.call(:c@com,NectarNode.Server,:receive_oplog_entry,[{1,{:write,1,2}}]))
        
      end
    end
  end
end