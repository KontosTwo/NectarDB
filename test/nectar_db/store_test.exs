defmodule NectarDb.StoreTest do
  use ExUnit.Case, async: false

  alias NectarDb.Store

  setup do
    require IEx; IEx.pry
    {:ok, _bucket} = start_supervised({Store,[]})
    
  end

  describe "adding and getting values from Store" do
    test "stores and retrieves 1 value" do
      Store.store_kv(1,2)
      assert 2 == Store.get_v(1)
    end
  end
end