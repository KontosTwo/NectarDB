defmodule NectarDb.Server do
  alias NectarDb.Store
  alias NectarDb.Oplog
  alias NectarDb.Memtable
  alias NectarDb.TaskSupervisor
  alias NectarDb.Clock
  alias NectarDb.Changelog

  use GenServer

  @me __MODULE__
  @max_time 11533521502368871000

  @type time :: integer
  @type key :: any
  @type value :: any
  @type kv :: %{key => value}
  @type operation :: {:write, key, value} | {:delete, key} | {:rollback, time}
  @type oplog_entry :: {time, operation}
  @type changelog_entry :: {:write,key,value} | {:delete,key}

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  @impl true
  def init(:no_args) do
    {:ok, nil}
  end


  @doc """

  """
  @spec write(key, value) :: :ok
  def write(key, value) do
    GenServer.call(@me, {:write,key,value})
  end

  @doc """

  """
  @spec delete(key) :: :ok
  def delete(key) do
    GenServer.call(@me, {:delete,key})
  end

  @doc """

  """
  @spec read(key) :: value
  def read(key) do
    GenServer.call(@me, {:read,key}, 1000000)
  end


  @doc """

  """
  @spec rollback(time) :: :ok
  def rollback(time) when is_integer(time) do
    GenServer.call(@me, {:rollback,time})
  end

  @doc """

  """
  @spec get_history() :: [oplog_entry]
  def get_history() do
    GenServer.call(@me,:get_history)
  end

  @spec receive_oplog_entry(oplog_entry) :: :ok
  def receive_oplog_entry(oplog_entry) do
    GenServer.call(@me, {:receive_oplog_entry,oplog_entry})
  end

  @doc """

  """
  @spec health_check() :: boolean
  def health_check() do
    GenServer.call(@me,:health_check)
  end

  @impl true
  def handle_call({:write, key, value},_from, state) do
    Oplog.add_log({Clock.get_time(),{:write, key, value}})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:delete, key},_from, state) do
    Oplog.add_log({Clock.get_time(),{:delete, key}})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:read, key},_from, state) do
    time = Clock.get_time()
    store_before = Store.get_all()

    sorted_oplog =
      Oplog.get_logs()
      |> List.keysort(0)

    # test read-repair if oplog is empty
    reverse_sorted_oplog =
      sorted_oplog
      |> Enum.reverse()

    #test if changelog is empty
    sorted_changelogs =
      Changelog.get_changelogs()
      |> Enum.sort_by(fn {time, _entry} -> time end)

    reverse_sorted_changelogs =
      sorted_changelogs
      |> Enum.reverse()

    last_read = case reverse_sorted_changelogs do
      [] -> :none
      [{time,_changelog} | _t] -> time
    end
    earliest_oplog_time = case sorted_oplog do
      [] -> :none
      [{time,_operation} | _t] -> time
    end

    affected_changelogs = cond do
      last_read == :none -> []
      earliest_oplog_time == :none -> []
      earliest_oplog_time < last_read ->
        {_previous_time, changelogs} =
          Enum.reduce reverse_sorted_changelogs, {@max_time,[]}, fn({time,operations},{previous_time,logs}) ->
            cond do
              previous_time < earliest_oplog_time -> {previous_time,logs}
              true -> {time,[{time,operations} | logs]}
            end
          end
        changelogs
      true -> []
    end

    reverse_sorted_affected_changelogs = affected_changelogs
      |> Enum.reverse()

    {earliest_affected_read,_operations} = case reverse_sorted_affected_changelogs do
      [h | _t] -> h
      [] -> {:none,[]}
    end


    memtable = Memtable.get_logs()
    all_sorted_oplogs = (sorted_oplog ++ memtable)
      |> List.keysort(0)

    affected_oplogs = case {earliest_affected_read,last_read} do
      {:none,_} -> []
      {_,:none} -> []
      {earliest,last} -> Enum.filter all_sorted_oplogs, fn {time,_operation} ->
        time > earliest and time < last
      end
    end

    require IEx; IEx.pry
    
    
    apply_changelog(affected_changelogs)

    #affected_oplogs should only be the ones before the last read
    Enum.reduce affected_changelogs, affected_oplogs, fn ({changelog_time,operations},remaining) ->
      before = Store.get_all()
      current_oplogs = Enum.take_while(remaining, fn {oplog_time,_operation} -> oplog_time < changelog_time end)
      remaining_oplogs = Enum.drop_while(remaining, fn {oplog_time,_operation} -> oplog_time < changelog_time end) 
      apply_write(current_oplogs)
      after_ = Store.get_all()
      diff = get_diff(changelog_time,before,after_)
      Changelog.add_changelog(diff)
      remaining_oplogs
    end


    pruned_oplog = Enum.reduce affected_oplogs, sorted_oplog, fn affected, acc ->
      case affected do
        [h | _t] -> List.delete(acc,h) 
        [] -> acc
      end
    end

    memtable_task = Task.Supervisor.async(TaskSupervisor,fn ->
      Enum.each(sorted_oplog, fn {time, operation} ->
        Memtable.add_log(time, operation)
      end)
    end)


    # needs to undo changesets
    rollbacked_oplog = Enum.reduce(pruned_oplog, [], fn entry, acc->
      case entry do
        {_time,{:rollback,to}} -> rollback_oplog(acc,to)
        other_entry -> [other_entry | acc]
      end
    end)
    |> Enum.reverse

    write_task = Task.Supervisor.async(TaskSupervisor,fn ->
      apply_write(rollbacked_oplog)
    end)

    Oplog.flush()

    Task.await(write_task)

    store_after = Store.get_all()
    changelog_task = Task.Supervisor.async(TaskSupervisor,fn ->
      diff = get_diff(time,store_before,store_after)
      Changelog.add_changelog(diff)
    end)

    value = Store.get_v(key)

    Task.await(memtable_task)
    Task.await(changelog_task)

    {:reply, value, state}
  end

  @impl true
  def handle_call({:rollback, to},_from, state) do
    Oplog.add_log({Clock.get_time(),{:rollback,to}})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:get_history,_from, state) do
    history = Oplog.get_logs() ++ Memtable.get_logs()
      |> List.keysort(0)
    {:reply, history,state}
  end

  @impl true
  def handle_call(:health_check,_from, state) do
    {:reply, Node.alive?(),state}
  end

  @impl true
  def handle_call({:receive_oplog_entry,oplog_entry},_from, state) do
    Oplog.add_log(oplog_entry)
    {:reply, :ok,state}
  end

  @spec apply_write([oplog_entry]) :: :ok
  defp apply_write(oplogs) do
    Enum.map oplogs, fn {_time, operation} ->
      case operation do
        {:write, key, value} ->
          Store.store_kv(key, value)
        {:delete, key} ->
          Store.delete_k(key)
        _ ->
          nil
      end
    end
    :ok
  end

  @spec rollback_oplog([oplog_entry],integer) :: [oplog_entry]
  defp rollback_oplog(oplog_entries,to) when is_list(oplog_entries) and is_integer(to) do
    Enum.reduce oplog_entries, [], fn {time,op}, acc ->
      if time > to, do: acc, else: [{time,op} | acc]
    end
  end

  @spec get_diff(integer,%{},%{}) :: {time,[changelog_entry]}
  defp get_diff(time,before, after_) do
    changelog = []
    b_keys = Map.keys(before)
    a_keys = Map.keys(after_)
    removed =  b_keys -- a_keys
    added = a_keys -- b_keys
    stayed = Enum.reduce a_keys ,[], fn element,acc ->
      if element in b_keys, do: [element | acc], else: acc
    end

    changelog = Enum.reduce removed, changelog,fn (key,changelog) ->
      [{:write,key,before[key]} | changelog]
    end

    changelog = Enum.reduce added, changelog,fn (key,changelog) ->
      [{:delete,key} | changelog]
    end

    changelog = Enum.reduce stayed, changelog,fn (key,changelog) ->
      cond do
        before[key] == after_[key] -> changelog
        before[key] != after_[key] -> [{:write,key,before[key]} | changelog]
      end
    end

    {time, changelog}
  end

  @spec apply_changelog([changelog_entry]) :: :ok
  defp apply_changelog(changelogs) do
    Enum.each changelogs, fn {_time, operation} ->
      case operation do
        {:write, key, value} ->
          Store.store_kv(key, value)
        {:delete, key} ->
          Store.delete_k(key)
        [delete: key] ->
          Store.delete_k(key)          
      end
      Changelog.rollback_changelog()
    end
    :ok
  end
end
