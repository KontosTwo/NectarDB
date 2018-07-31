defmodule NectarDb.Server do
  alias NectarDb.Store
  alias NectarDb.Oplog
  alias NectarDb.Memtable
  alias NectarDb.TaskSupervisor

  @type key :: any
  @type value :: any
  @type kv :: %{key => value}
  @type operation :: {:write, key, value} | {:delete, key}
  @type oplog_entry :: {integer, operation}

  @doc """
    
  """
  @spec write(key, value) :: :ok
  def write(key, value) do
    task = Task.Supervisor.async(TaskSupervisor,fn ->
      System.monotonic_time(:seconds)
      |> Oplog.add_log({:write, key, value})
    end)
    Task.await(task)
    :ok
  end

  @doc """
    
  """
  @spec delete(key) :: :ok
  def delete(key) do
    task = Task.Supervisor.async(TaskSupervisor,fn ->
      System.monotonic_time(:seconds)
      |> Oplog.add_log({:delete, key})
    end)

    Task.await(task)

    :ok
  end

  @doc """

  """
  @spec read(key) :: value
  def read(key) do
    sorted_oplog =
      Oplog.get_logs()
      |> List.keysort(0)

    memtable_task = Task.Supervisor.async(TaskSupervisor,fn ->
      Enum.each(sorted_oplog, fn {time, operation} ->
        Memtable.add_log(time, operation)
      end)
    end)

    write_tasks = Enum.map sorted_oplog, fn {_time, operation} ->
      Task.Supervisor.async(TaskSupervisor,fn ->
        case operation do
          {:write, key, value} ->
            Store.store_kv(key, value)

          {:delete, key} ->
            Store.delete_k(key)

          _ ->
            nil
        end
      end)
    end

    Oplog.flush()
    
    Task.await(memtable_task)
    Enum.each write_tasks, fn write_task ->
      Task.await(write_task)
    end

    Store.get_v(key)
  end

  @doc """

  """
  @spec get_history() :: [oplog_entry]
  def get_history() do
    task = Task.Supervisor.async(TaskSupervisor,fn ->
      Oplog.get_logs() ++ Memtable.get_logs()
    end)
    Task.await task
  end

  @doc """

  """
  def health_check() do
    Node.alive? 
  end
end
