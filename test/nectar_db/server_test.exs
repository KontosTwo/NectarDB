defmodule ServerTest do
  use ExUnit.Case, async: true

  alias NectarDb.Store
  alias NectarDb.Oplog
  alias NectarDb.Memtable
  alias NectarDb.Server

  import Mock

  setup do
    start_supervised!(Store)
    start_supervised!(Oplog)
    start_supervised!(Memtable)
    start_supervised!({Task.Supervisor,name: NectarDb.TaskSupervisor})    
    :ok
  end

  describe "write a key value pair" do
    test "succeeds" do
      with_mock(System, [monotonic_time: fn (_type) -> 1 end]) do
        Server.write(1,2)        
      end

      assert [{1,{:write, 1, 2}}] == Oplog.get_logs()
    end
  end

  describe "delete a key value pair" do
    test "succeeds" do
      with_mock(System, [monotonic_time: fn (_type) -> 1 end]) do
        Server.write(1,2)        
      end      
      with_mock(System, [monotonic_time: fn (_type) -> 2 end]) do
        Server.delete(1)        
      end
      assert [{2,{:delete, 1}},{1,{:write, 1, 2}}] = Oplog.get_logs()
    end
  end

  describe "reads a key" do
    test "returns correct value" do
      Server.write(1,2)

      assert 2 == Server.read(1)
    end

    test "returns correct value with consecutive writes" do
      with_mock(System, [monotonic_time: fn (_type) -> 1 end]) do
        Server.write(1,2)        
      end  
      with_mock(System, [monotonic_time: fn (_type) -> 2 end]) do
        Server.write(1,3)        
      end  

      assert 3 == Server.read(1)
    end

    test "returns correct value with write followed by delete" do
      with_mock(System, [monotonic_time: fn (_type) -> 1 end]) do
        Server.write(1,2)        
      end  
      with_mock(System, [monotonic_time: fn (_type) -> 2 end]) do
        Server.delete(1)        
      end  

      assert nil == Server.read(1)
    end

    test "returns correct value with operations out of order" do
      with_mock(System, [monotonic_time: fn (_type) -> 2 end]) do
        Server.delete(1)        
      end  
      with_mock(System, [monotonic_time: fn (_type) -> 1 end]) do
        Server.write(1,2)           
      end  

      assert nil == Server.read(1)
    end

    test "oplog is flushed" do
      Server.write(1,2)           

      Server.read(1)

      assert [] == Oplog.get_logs()
    end

    test "memtable gets written to" do
      Server.write(1,2)           

      Server.read(1)

      assert [{_,{:write, 1, 2}}] = Memtable.get_logs()
    end
  end

  describe "gets history" do
    test "correct history for unflushed oplog" do
      Server.write(1,2)           

      assert [{_,{:write, 1, 2}}] = Server.get_history()
    end

    test "correct history for flushed oplog and written memtable" do
      Server.write(1,2)           
      Server.read(1)
      assert [{_,{:write, 1, 2}}] = Server.get_history()
    end

    test "correct history for flushed and repopulated oplog and written memtable" do
      Server.write(1,2)           
      Server.read(1)
      Server.write(2,2)                 
      assert [{_,{:write, 2, 2}},{_,{:write, 1, 2}}] = Server.get_history()
    end
  end

  describe "check health of server" do
    test "healthy server returns true" do
      assert Server.health_check()
    end
  end
end