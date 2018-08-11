defmodule NectarHub.Router.Hub do
  use GenServer

  @me __MODULE__

  @type key :: any
  @type value :: any
  @type time :: integer

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :init, name: @me)
  end

  @spec write(time,key, value) :: :ok
  def write(time,key, value) do
    GenServer.call(@me, {:write, time, key, value})
  end

  @spec read(time,key) :: value
  def read(time,key) do
    GenServer.call(@me, {:read, time, key})  
  end

  @spec delete(time,key) :: :ok  
  def delete(time,key) do
    GenServer.call(@me, {:delete, time, key})
  end

  def init(:init) do
    {:ok, []}
  end 

  def handle_call({:write, time, key, value}, _from, state) do

    {:reply, :ok, state}
  end

  def handle_call({:read, time, key}, _from, state) do

    {:reply, :ok, state}
  end

  def handle_call({:delete, time, key}, _from, state) do

    {:reply, :ok, state}
  end
end