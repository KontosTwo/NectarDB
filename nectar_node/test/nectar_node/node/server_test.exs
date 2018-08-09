defmodule ServerTest do
  use ExUnit.Case, async: true

  alias NectarNode.Store
  alias NectarNode.Oplog
  alias NectarNode.Memtable
  alias NectarNode.Server
  alias NectarNode.Changelog  

  setup do
    #  gotta install epmd
    start_supervised!(Server)
    start_supervised!(Store)
    start_supervised!(Oplog)
    start_supervised!(Memtable)
    start_supervised!(Changelog)
    start_supervised!({Task.Supervisor,name: NectarNode.TaskSupervisor})
    :ok
  end

  describe "write a key value pair" do
    test "succeeds" do
      Server.write(1,1,2)

      assert [{1,{:write, 1, 2}}] == Oplog.get_logs()
    end
  end

  describe "delete a key value pair" do
    test "succeeds" do
      Server.write(1,1,2)
      Server.delete(2,1)

      assert [{2,{:delete, 1}},{1,{:write, 1, 2}}] = Oplog.get_logs()
    end
  end

  describe "reads a key" do
    test "returns correct value" do
      Server.write(1,1,2)

      assert 2 == Server.read(1,1)
    end

    test "returns nothing if nothing was written" do
      assert nil == Server.read(1,1)
    end

    test "returns correct value with consecutive writes" do
      Server.write(1,1,2)
      Server.write(2,1,3)

      assert 3 == Server.read(3,1)
    end

    test "returns correct value with write followed by delete" do
      Server.write(1, 1,2)
      Server.delete(2, 1)

      assert nil == Server.read(3,1)
    end

    test "returns correct value with operations out of order" do
      Server.delete(2, 1)
      Server.write(1,1,2)

      assert nil == Server.read(3,1)
    end

    test "oplog is flushed for read" do
      Server.write(1,1,2)
      Server.read(2,1)

      assert [] == Oplog.get_logs()
    end

    test "memtable gets written to for read" do
      Server.write(2,1,2)
      Server.write(1,1,2)
      Server.read(3,1)

      assert [{2,{:write, 1, 2}},{1,{:write, 1, 2}}] = Memtable.get_logs()
    end

    test "changelog updated for read" do
      Store.store_kv(3,1)
      Store.store_kv(2,1)      
      Server.write(1,1,1)
      Server.write(5,2,2)
      Server.delete(7,3)
      Server.read(10,1)

      changelogs = Changelog.get_changelogs()
      assert [{10, [{:write, 2, 1}, {:delete, 1}, {:write, 3, 1}]}, {0, []}] == changelogs
    end

    test "delayed operation originating before read arrives after read" do
      Server.write(1,1,1)
      Server.write(5,1,2)
      Server.read(10,1)
      Server.delete(3,1)
      
      assert 2 == Server.read(20,1)
      assert Store.get_v(1) == 2    
      assert Changelog.get_changelogs == [{20, []}, {10, [delete: 1]}, {0, []}] 
      assert Oplog.get_logs == []      
      assert Memtable.get_logs() == [{3, {:delete, 1}}, {5, {:write, 1, 2}}, {1, {:write, 1, 1}}]
    end

    test "delayed operation is the very first operation" do
      Server.write(5,1,2)
      Server.read(10,1)
      Server.delete(3,1)

      assert 2 == Server.read(20,1)
      assert Store.get_v(1) == 2    
      assert Changelog.get_changelogs == [{20, []}, {10, [delete: 1]}, {0, []}] 
      assert Oplog.get_logs == []      
      assert Memtable.get_logs() == [{3, {:delete, 1}}, {5, {:write, 1, 2}}]
    end

    test "delayed operation is the only operation" do
      Server.read(10,1)
      Server.write(5,1,2)

      assert 2 == Server.read(20,1)
      assert Store.get_v(1) == 2    
      assert Changelog.get_changelogs == [{20, []}, {10, [delete: 1]}, {0, []}]
      assert Oplog.get_logs == []      
      assert Memtable.get_logs() == [{5, {:write, 1, 2}}]
    end

    test "two consecutive reads" do
      Server.read(10,1)
      Server.read(10,1)
      assert nil == Server.read(10,1)
      assert Store.get_v(1) == nil    
      assert Changelog.get_changelogs == [{10, []}, {10, []}, {10, []}, {0, []}]
      assert Oplog.get_logs == []      
      assert Memtable.get_logs() == []
    end
  end

  describe "gets history" do
    test "correct history for unflushed oplog" do
      Server.write(1,1,2)

      assert [{1,{:write, 1, 2}}] = Server.get_history()
    end

    test "correct history for flushed oplog and written memtable" do
      Server.write(1,1,2)
      Server.read(2,1)
      assert [{1,{:write, 1, 2}}] = Server.get_history()
    end

    test "correct history for flushed and repopulated oplog and written memtable" do
      Server.write(1,1,2)
      Server.read(2,1)
      Server.write(3,2,2)
      assert [{1,{:write, 1, 2}},{3,{:write, 2, 2}}] = Server.get_history()
    end

    test "history is sorted" do
      Server.write(2,1,2)

      Server.write(1,1,3)

      Server.read(2,1)

      Server.write(4,2,2)

      Server.write(3,2,3)

      assert [
        {1, {:write, 1, 3}},
        {2, {:write, 1, 2}},
        {3, {:write, 2, 3}},
        {4, {:write, 2, 2}}
      ] = Server.get_history()
    end
  end

  describe "check health of server" do
    test "healthy server returns true" do
      Node.start(:a@localhost, :shortnames)
      assert Server.health_check()
    end

    test "dead server returns false" do
      Node.start(:a@localhost, :shortnames)
      Node.stop()
      refute Server.health_check()
    end
  end
end
