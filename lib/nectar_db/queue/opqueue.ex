defmodule NectarDb.Opqueue do
  use GenServer

  alias NectarDb.OpqueueSupervisor

  @me __MODULE__

  @type time :: integer
  @type key :: any
  @type value :: any
  @type operation :: {:write, key, value} | {:read, key} | {:delete, key} | {:rollback, time}
  @type oplog_entry :: {time, operation}

  @spec start_link(any) :: {:ok, pid}
  def start_link(num_workers) do
    GenServer.start_link(__MODULE__, num_workers, name: @me) 
  end

  @spec queue_operation(oplog_entry) :: :ok
  def queue_operation(oplog_entry) do
    GenServer.cast(@me, {:queue_operation,oplog_entry})
  end

  @spec next_operation() :: oplog_entry | :no_more
  def next_operation() do
    GenServer.call(@me, :next_operation)
  end


  def init(num_workers) do
    Process.send_after(self(),{:init_workers,num_workers},0)
    {:ok,[]}
  end

  def handle_info({:init_workers, number},state) do
    for i <- 1..number, i > 0 do
      OpqueueSupervisor.add_worker()
    end
    {:noreply,state}
  end

  def handle_cast({:queue_operation, operation}, operations) do
    {:noreply, [operation|operations]}
  end

  def handle_call(:next_operation, _from, oplog_entries) do
    case oplog_entries do
      [h | t] -> {:reply, h, t}
      [] -> {:reply,:no_more,oplog_entries}
    end
  end
end