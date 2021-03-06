defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      loop(callback_module, HashDict.new)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {request, self})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  defp loop(callback_module, current_state) do
    receive do
      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
      {request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)
    end
  end
end

defmodule KeyValueStore do
  def start do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
    ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def handle_call({:put, key, value}, state) do
    {:ok, HashDict.put(state, key, value)}
  end

  def handle_cast({:put, key, value}, state) do
    HashDict.put(state, key, value)
  end

  def handle_call({:get, key}, state) do
    {HashDict.get(state, key), state}
  end
end
