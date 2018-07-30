defmodule NectarDb.Server do
  alias NectarDb.Store
  alias NectarDb.Oplog
  alias NectarDb.Memtable

  @type key :: any
  @type value :: any
  @type kv :: %{key => value}
  @type operation :: {:write, key, value} | {:delete, key}
  @type oplog_entry :: {integer, operation}

  @doc """
    
  """
  @spec write(key, value) :: :ok
  def write(key, value) do
    Task.async(fn ->
      :os.system_time(:seconds)
      |> Oplog.add_log({:write, key, value})
    end)

    :ok
  end

  @doc """
    
  """
  @spec delete(key) :: :ok
  def delete(key) do
    Task.async(fn ->
      :os.system_time(:seconds)
      |> Oplog.add_log({:delete, key})
    end)

    :ok
  end

  @doc """

  """
  @spec read(key) :: value
  def read(key) do
    sorted_oplog =
      Oplog.get_logs()
      |> List.keysort(0)

    Enum.each(sorted_oplog, fn {_time, operation} ->
      case operation do
        {:write, key, value} ->
          Store.store_kv(key, value)

        {:delete, key} ->
          Store.delete_k(key)

        _ ->
          nil
      end
    end)

    Task.async(fn ->
      Enum.each(sorted_oplog, fn {time, operation} ->
        Memtable.add_log(time, operation)
      end)
    end)

    Oplog.flush()
    Store.get_v(key)
  end

  @doc """

  """
  @spec get_history() :: [oplog_entry]
  def get_history() do
    Oplog.get_logs() ++ Memtable.get_logs()
  end
end
