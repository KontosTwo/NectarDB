defmodule NectarDb.ListManipTest do
  use ExUnit.Case,async: true

  alias NectarDb.ListManip

  describe "reverse a list" do
    test "reverses empty list" do
      assert [] = ListManip.reverse([])
    end

    test "reverses single-element list" do
      assert [1] = ListManip.reverse([1])
    end

    test "reverses two-element list" do
      assert [2,1] = ListManip.reverse([1,2])
    end

    test "reverses three-element list" do
      assert [3,2,1] = ListManip.reverse([1,2,3])
    end
  end
end
