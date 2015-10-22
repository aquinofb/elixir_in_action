defmodule KeyValueStore do
  use GenServer

  def init(_) do
    {:ok, HashDict.new}
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, HashDict.put(state, key, value)}
  end

  def handle_call({:get, key}, _, state) do
    {:reply, HashDict.get(state, key), state}
  end
end
