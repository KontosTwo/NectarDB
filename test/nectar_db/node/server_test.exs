defmodule ServerTest do
  use ExUnit.Case, async: true

  alias NectarDb.Store
  alias NectarDb.Oplog
  alias NectarDb.Memtable
  alias NectarDb.Server
  alias NectarDb.Clock
  alias TestHelper.TestTimekeeper

  setup do
    #  gotta install epmd
    start_supervised!(TestTimekeeper)
    start_supervised!({Clock,fn -> TestTimekeeper.get_time() end})
    start_supervised!(Server)
    start_supervised!(Store)
    start_supervised!(Oplog)
    start_supervised!(Memtable)
    start_supervised!({Task.Supervisor,name: NectarDb.TaskSupervisor})
    :ok
  end

  describe "write a key value pair" do
    test "succeeds" do
      TestTimekeeper.set_time(1)
      Server.write(1,2)

      assert [{1,{:write, 1, 2}}] == Oplog.get_logs()
    end
  end

  describe "delete a key value pair" do
    test "succeeds" do
      TestTimekeeper.set_time(1)

      Server.write(1,2)
      TestTimekeeper.set_time(2)

      Server.delete(1)
      assert [{2,{:delete, 1}},{1,{:write, 1, 2}}] = Oplog.get_logs()
    end
  end

  describe "reads a key" do
    test "returns correct value" do
      Server.write(1,2)

      assert 2 == Server.read(1)
    end

    test "returns correct value with consecutive writes" do
      TestTimekeeper.set_time(1)

      Server.write(1,2)
      TestTimekeeper.set_time(2)

      Server.write(1,3)

      assert 3 == Server.read(1)
    end

    test "returns correct value with write followed by delete" do
      TestTimekeeper.set_time(1)

      Server.write(1,2)
      TestTimekeeper.set_time(2)

      Server.delete(1)

      assert nil == Server.read(1)
    end

    test "returns correct value with operations out of order" do
      TestTimekeeper.set_time(2)

      Server.delete(1)
      TestTimekeeper.set_time(1)

      Server.write(1,2)
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

  describe "rollback" do
    test "no rollback on empty oplog and memtable" do
      TestTimekeeper.set_time(1)
      Server.rollback(1)
    end

    test "rollback for 1 operation" do
      TestTimekeeper.set_time(5)
      Server.write(1,2)
      TestTimekeeper.set_time(6)
      Server.rollback(3)
      assert nil == Server.read(1)
    end

    test "rollback for 3 operation" do
      TestTimekeeper.set_time(3)
      Server.write(1,2)
      TestTimekeeper.set_time(4)
      Server.write(2,2)
      TestTimekeeper.set_time(5)
      Server.write(3,2)
      TestTimekeeper.set_time(6)
      Server.rollback(1)
      assert nil == Server.read(1)
      assert nil == Server.read(2)
      assert nil == Server.read(3)
    end

    test "does not rollback earlier operations" do
      TestTimekeeper.set_time(3)
      Server.write(1,2)
      TestTimekeeper.set_time(5)
      Server.write(2,2)
      TestTimekeeper.set_time(6)
      Server.rollback(4)

      assert 2 == Server.read(1)
      assert nil == Server.read(2)
    end

    test "multiple rollbacks overlapping" do
      TestTimekeeper.set_time(3)
      Server.write(1,2)
      TestTimekeeper.set_time(5)
      Server.write(2,2)
      TestTimekeeper.set_time(6)
      Server.rollback(4)
      TestTimekeeper.set_time(7)
      Server.write(1,2)
      TestTimekeeper.set_time(8)
      Server.write(2,2)
      TestTimekeeper.set_time(9)
      Server.rollback(2)

      assert nil == Server.read(1)
      assert nil == Server.read(2)
    end

    test "rollback oplog entries are written to memtable" do
      TestTimekeeper.set_time(3)
      Server.write(1,2)
      TestTimekeeper.set_time(5)
      Server.write(2,2)
      TestTimekeeper.set_time(6)
      Server.rollback(4)
      assert 2 == Server.read(1)

      memtable = Memtable.get_logs()
      assert {_,{:rollback,_}} = Enum.at(memtable,0)
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
