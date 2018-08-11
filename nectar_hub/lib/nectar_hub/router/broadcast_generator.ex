defmodule NectarHub.Router.BroadcastGenerator do
  use GenStage

  alias NectarHub.Util.Queue

  @me __MODULE__
  
  @type key :: any
  @type value :: any
  @type time :: integer
  @type operation :: {:write, time, key, value} | {:read, time, key} | {:delete, time, key}  

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenStage.start_link(__MODULE__, :no_args, name: @me)
  end




  def init(:no_args) do
    {:producer, Queue.new}
  end

  @impl true
  def handle_call({:broadcast,operations},_from, messages) do
    new_messages = Enum.reduce operations, messages, fn operation, acc ->
      Queue.insert(acc,operation)
    end

    {:reply,:ok,:ok,new_messages}
  end

  def handle_demand() do

  end
end