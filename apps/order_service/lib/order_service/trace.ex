defmodule OrderService.Trace do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: Trace)
  end

  def init(start) do
    {:ok, start}
  end

  def action(trace, entity, action) do
    GenServer.cast(trace, {:action, entity, action})
  end

  def actions(trace, entity) do
    GenServer.call(trace, {:actions, entity})
  end

  def handle_cast({:action, entity, action}, history) do
    IO.puts("handling action from #{inspect entity}")
    {:noreply, [{entity, action} | history]}
  end

  def handle_call({:actions, entity}, _from, history) do
    actions = Enum.filter_map(history,
     fn({e, a}) -> entity = e end,
     fn({e, a}) -> a end)

    {:reply, actions, history}
  end
end
