defmodule NectarAPIWeb.OperationServiceTest do
  use ExUnit.Case, async: false

  alias NectarAPIWeb.OperationService
  alias NectarAPI.Clock
  alias NectarAPI.Queue
  
  setup do
    start_supervised!(Clock)
    :ok
  end

  describe "parsing write" do
    test "succeeds for empty list" do
      writes = [
        
      ]
      parsed = OperationService.parse_write(writes)
      list = Queue.to_list(parsed)
      assert list == []
    end

    test "succeeds for write" do
      writes = [
        %{
          "type" => "write",
          "key" => 1,
          "value" => 2
        },
      ]
      parsed = OperationService.parse_write(writes)
      list = Queue.to_list(parsed)      
      assert list == [{0,{:write, 1, 2}}]
    end

    test "succeeds for delete" do
      writes = [
        %{
          "type" => "delete",
          "key" => 1
        },
      ]
      parsed = OperationService.parse_write(writes)
      list = Queue.to_list(parsed)      
      assert list == [{0,{:delete, 1}}]
    end

    test "succeeds for read and delete" do
      writes = [
        %{
          "type" => "delete",
          "key" => 1
        }, 
        %{
          "type" => "write",
          "key" => 1,
          "value" => 2
        },
      ]
      parsed = OperationService.parse_write(writes)
      list = Queue.to_list(parsed)            
      assert list == [{0,{:delete, 1}},{1,{:write, 1,2}}]
    end
  end

  describe "parsing read" do
    test "succeeds for empty list" do
      reads = [
        
      ]
      parsed = OperationService.parse_read(reads)
      list = Queue.to_list(parsed)
      assert list == []
    end

    test "succeeds for one read" do
      reads = [
        %{
          "type" => "read",
          "key" => 1
        }, 
      ]
      parsed = OperationService.parse_read(reads)
      list = Queue.to_list(parsed)
      assert list == [{0,{:read,1}}]
    end

    test "succeeds for multiple reads" do
      reads = [
        %{
          "type" => "read",
          "key" => 1
        }, 
        %{
          "type" => "read",
          "key" => 2
        }, 
      ]
      parsed = OperationService.parse_read(reads)
      list = Queue.to_list(parsed)
      assert list == [{0,{:read,1}},{1,{:read,2}}]
    end
  end
end