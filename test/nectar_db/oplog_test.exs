defmodule NectarDb.OplogTest do
  use ExUnit.Case, async: false

  alias NectarDb.Oplog

  describe "adding and retrieving logs from Oplog" do
    test "succeeds for addition" do
      {:ok, _bucket} = Oplog.start_link([])
      Oplog.add_log({:write, 1, 2})
      assert [{:write, 1, 2}] == Oplog.get_logs()
    end

    test "succeeds for multiple additions" do
      {:ok, _bucket} = Oplog.start_link([])
      Oplog.add_log({:write, 1, 2})
      Oplog.add_log({:read, 1})
      assert [{:read, 1}, {:write, 1, 2}] == Oplog.get_logs()
    end
  end
end
