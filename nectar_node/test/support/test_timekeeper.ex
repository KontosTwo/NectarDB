defmodule TestHelper.TestTimekeeper do
  use Agent

  @me __MODULE__

  def start_link(_args) do
    Agent.start_link(fn -> 0 end,name: @me)
  end

  def set_time(new_time) do
    Agent.update(@me, fn _time -> new_time end)
  end

  def get_time() do
    Agent.get(@me, fn time -> time end)
  end
end
