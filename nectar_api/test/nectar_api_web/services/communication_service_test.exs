defmodule NectarAPIWeb.CommunicationServiceTest do
  use ExUnit.Case, async: false

  alias NectarAPIWeb.CommunicationService
  alias NectarAPI.Broadcast.RPC
  alias NectarAPI.Router.Nodes
  #alias NectarAPI.Exceptions.ReadNodesUnresponsive
  
  import Mock

  setup do
    start_supervised!(Nodes)
    :ok
  end


  describe "communicate write" do
    test "succeeds after 1 write" do
      Nodes.add_node(:a@com)
      with_mock(RPC, call: fn _node,_module,_fun,_args -> 
        :ok
      end) do
        CommunicationService.write({1,{:write, 1, 2}})
        Process.sleep(10)
        assert_called RPC.call(:a@com,NectarNode.Server,:write,[1,1,2])
      end
    end

    test "succeeds after 1 write to multiple nodes" do
      Nodes.add_node(:a@com)
      Nodes.add_node(:b@com)
      Nodes.add_node(:c@com)
      
      with_mock(RPC, call: fn _node,_module,_fun,_args -> 
        :ok
      end) do
        CommunicationService.write({1,{:write, 1, 2}})
        Process.sleep(10)
        
        assert_called RPC.call(:a@com,NectarNode.Server,:write,[1,1,2])
        assert_called RPC.call(:b@com,NectarNode.Server,:write,[1,1,2])
        assert_called RPC.call(:c@com,NectarNode.Server,:write,[1,1,2])
      end
    end

    test "succeeds after 1 delete" do
      Nodes.add_node(:a@com)
      with_mock(RPC, call: fn _node,_module,_fun,_args -> 
        :ok
      end) do
        CommunicationService.write({1,{:delete, 1}})
        Process.sleep(10)        
        assert_called RPC.call(:a@com,NectarNode.Server,:delete,[1,1])
      end
    end

    test "succeeds after 1 delete to multiple nodes" do
      Nodes.add_node(:a@com)
      Nodes.add_node(:b@com)
      Nodes.add_node(:c@com)
      
      with_mock(RPC, call: fn _node,_module,_fun,_args -> 
        :ok
      end) do
        CommunicationService.write({1,{:delete, 1}})
        Process.sleep(10)
        
        assert_called RPC.call(:a@com,NectarNode.Server,:delete,[1,1])
        assert_called RPC.call(:b@com,NectarNode.Server,:delete,[1,1])
        assert_called RPC.call(:c@com,NectarNode.Server,:delete,[1,1])
      end
    end
  end

  describe "communicate read" do
        
    test "succeeds after 1 read" do
      Nodes.add_node(:a@com)
      
      with_mock(RPC, call: fn _node,_module,_fun,_args -> 
        2
      end) do
        assert 2 = CommunicationService.read({1,{:read, 1}})
        assert_called RPC.call(:a@com,NectarNode.Server,:read,[1,1])
      end
    end

    test "succeeds after 1 read from multiple nodes" do
      Nodes.add_node(:a@com)
      Nodes.add_node(:b@com)
      Nodes.add_node(:c@com)
      
      with_mock(RPC, call: fn _node,_module,_fun,_args -> 
        2
      end) do
        assert 2 = CommunicationService.read({1,{:read, 1}})
        assert_called RPC.call(:a@com,NectarNode.Server,:read,[1,1])
      end
    end

    test "succeeds eventually for one node" do

    end

    test "succeeds eventually for multiple nodes" do
      
    end

    test "raises error if only node is unresponsive" do
      # Nodes.add_node("a@com")
      
      # with_mock(RPC, call: fn _node,_module,_fun,_args -> 
      #   {:badrpc, :reason}
      # end) do
      #   Process.flag :trap_exit, true
      #   pid = self()

      #   catch_exit do
      #     CommunicationService.read({1,{:read, 1}})          
      #   end

      #   assert_received({:EXIT, _, {%ReadNodesUnresponsive{message: _}, _}})

      # end
    end

    test "raises error if every node is unresponsive" do

    end

    test "eventually fails" do
      # with_mock(RPC, call: fn _node,_module,_fun,_args -> 
      #   {:badrpc, :reason}
      # end) do
      # end
    end
  end
end