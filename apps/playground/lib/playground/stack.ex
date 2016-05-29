# A small example program to be inspected. Stolen from:
#   http://elixir-lang.org/docs/stable/elixir/GenServer.html
defmodule Playground.Stack do
  use GenServer

  # Client
  
  def start_link() do
    GenServer.start_link(__MODULE__, [], [{:name, :stack}])
  end

  def push(pid, item) do
    GenServer.cast(pid, {:push, item})
  end

  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Callbacks

  def handle_call(:pop, _from, [h|t]) do
    {:reply, h, t}
  end

  def handle_cast({:push, item}, state) do
    {:noreply, [item|state]}
  end

end
