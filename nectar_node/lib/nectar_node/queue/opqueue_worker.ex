defmodule NectarNode.OpqueueWorker do
  use GenServer

  alias NectarNode.Oplog
  alias NectarNode.Opqueue

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :no_args)
  end



  
  @impl true
  def init(:no_args) do
    Process.send_after(self(), :do_one_op, 0)
    
    {:ok,nil}
  end

  @impl true
  def handle_info(:do_one_op,state) do
    case Opqueue.next_operation() do
      {time,operation} -> Oplog.add_log({time,operation})
      :no_more -> nil
    end

    send(self(), :do_one_op)
    {:noreply,state}
  end
end