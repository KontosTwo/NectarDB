defmodule NectarAPIWeb.CommunicationServiceTest do
  use ExUnit.Case, async: false

  alias NectarAPIWeb.CommunicationService
  alias NectarAPI.Broadcast.RPC
  alias NectarAPIWeb.SucceedAfter

  import Mock
  import GenRetry

  @retries_per_write 10
  @retries_per_read 10

  setup do
    start_supervised!({Task.Supervisor,[name: Some]})
    :ok
  end


  describe "communicate write" do
    test "succeeds after 1 write" do
      with_mock(RPC, call: fn _node,_module,_fun,_args -> 
        :ok
      end) do
        CommunicationService.write(:a@com,{1,{:write, 1, 2}})
      end
    end

    test "succeeds after 1 delete" do
      with_mock(RPC, call: fn _node,_module,_fun,_args -> 
        :ok
      end) do
        CommunicationService.write(:a@com,{1,{:delete, 1}})
      end
    end
  end

  describe "communicate read" do
    test "succeeds after 1 read" do
      with_mock(RPC, call: fn _node,_module,_fun,_args -> 
        2
      end) do
        assert 2 = CommunicationService.read(:a@com,{1,{:read, 1}})
      end
    end
  end
end