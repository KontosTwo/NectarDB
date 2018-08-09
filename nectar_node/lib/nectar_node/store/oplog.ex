defmodule NectarNode.Oplog do
  use Agent

  @me __MODULE__

  @type key :: any
  @type value :: any
  @type time :: integer
  @type log :: {:write, key, value} | {:delete, key} | {:read, key} | {:rollback, time}

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    Agent.start_link(fn -> [] end, name: @me)
  end

  @spec add_log({integer, log}) :: :ok
  def add_log({timestamp, log}) do
    Agent.cast(@me, fn logs ->
      [{timestamp, log} | logs]
    end)
  end

  @spec get_logs() :: [{integer, log}]
  def get_logs() do
    Agent.get(@me, fn logs ->
      logs
    end)
  end

  @spec flush() :: :ok
  def flush() do
    Agent.cast(@me, fn _logs -> [] end)
  end
end
