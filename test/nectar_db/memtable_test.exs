defmodule NectarDb.MemtableTest do
  use ExUnit.Case, async: true

  alias NectarDb.Memtable

  setup do
    start_supervised!(Memtable)
    :ok
  end

  describe "adding and retrieving logs from Oplog" do
    test "succeeds for addition" do
      Memtable.add_log(0,{:write, 1, 2})
      assert [{0,{:write, 1, 2}}] == Memtable.get_logs()
    end

    test "succeeds for multiple additions" do
      Memtable.add_log(0,{:write, 1, 2})
      Memtable.add_log(1,{:read, 1})
      assert [{1,{:read, 1}}, {0,{:write, 1, 2}}] == Memtable.get_logs()
    end
  end
end
