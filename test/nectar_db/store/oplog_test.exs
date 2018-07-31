defmodule NectarDb.OplogTest do
  use ExUnit.Case, async: true

  alias NectarDb.Oplog

  setup do
    start_supervised!(Oplog)
    :ok
  end

  describe "adding and retrieving logs from Oplog" do
    test "succeeds for addition" do
      Oplog.add_log(0,{:write, 1, 2})
      assert [{0,{:write, 1, 2}}] == Oplog.get_logs()
    end

    test "succeeds for multiple additions" do
      Oplog.add_log(0,{:write, 1, 2})
      Oplog.add_log(1,{:read, 1})
      assert [{1,{:read, 1}}, {0,{:write, 1, 2}}] == Oplog.get_logs()
    end
  end

  describe "flushing oplog" do
    test "results in an empty oplog" do
      Oplog.add_log(0,{:write, 1, 2})
      Oplog.flush()
      assert [] == Oplog.get_logs()
    end
  end
end
