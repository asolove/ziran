defmodule OrderService.Order do
  use GenServer

  # Client API

  def start_link(opts, id) do
    GenServer.start_link(__MODULE__, Dict.put(opts, :id, id))
  end

  def purchase(order) do
    GenServer.call(order, :purchase)
  end

  def cancel(order) do
    GenServer.call(order, :cancel)
  end

  # Callbacks

  def init(%{:id => id, :table => table} =opts) do
    attrs = attributes(table, id)
    IO.puts("Starting Order ##{opts.id} with attrs: #{inspect attrs}")
    {:ok, {id, attrs, opts}}
  end  
  
  def handle_call(:purchase, _from, {id, attrs, opts}) do
    attrs = %{attrs | state: "purchased"}
    save(opts.table, id, attrs)
    {:reply, :ok, {id, attrs, opts}}
  end

  def handle_call(:cancel, _fro, {id, attrs, opts}) do
    attrs = %{attrs | state: "canceled"}
    save(opts.table, id, attrs)
    {:reply, :ok, {id, attrs, opts}}
  end

  defp save(table, id, attrs) do
    :ets.insert(table, {id, attrs})
  end

  defp attributes(table, id) do
    case :ets.lookup(table, id) do
      [{id, attrs}] -> attrs
      _ -> default_attrs
    end
  end

  defp default_attrs do
    %{state: "start"}
  end
end
