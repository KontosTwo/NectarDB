defmodule NectarDb.StoreTest do
  use ExUnit.Case, async: true

  alias NectarDb.Store

  setup do
    start_supervised!(Store)
    :ok
  end

  describe "adding and getting values from Store" do
    test "stores and retrieves 1 value" do
      Store.store_kv(1, 2)
      assert 2 == Store.get_v(1)
    end

    test "stores and retrieves multiple values" do
      Store.store_kv(1, 2)
      Store.store_kv(2, 3)      
      assert 2 == Store.get_v(1)
      assert 3 == Store.get_v(2)      
    end

    test "stores and replaces value" do
      Store.store_kv(1, 2)
      Store.store_kv(1, 3)      
      assert 3 == Store.get_v(1)
    end
  end
end
