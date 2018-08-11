defmodule NectarHub.Time.ClockTest do
  use ExUnit.Case, async: true

  alias NectarAPI.Clock

  setup do
    start_supervised!(Clock)
    :ok
  end

  describe "getting and incrementing time" do
    test "succeeds" do
      assert 0 == Clock.get_and_tick()
      assert 1 == Clock.get_and_tick()      
      assert 2 == Clock.get_and_tick()            
    end
  end
end  