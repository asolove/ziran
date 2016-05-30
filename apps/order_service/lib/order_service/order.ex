defmodule OrderService.Order do
  use Entity

  # Client API

  def purchase(order) do
    GenServer.call(order, :purchase)
  end

  def cancel(order) do
    GenServer.call(order, :cancel)
  end

  def state(order) do
    GenServer.call(order, :state)
  end

  # Callbacks
  
  def _handle_call(:purchase, _from, attrs) do
    attrs = %{attrs | state: "purchased"}
    {:reply, :ok, attrs}
  end

  def _handle_call(:cancel, _from, attrs) do
    attrs = %{attrs | state: "canceled"}
    {:reply, :ok, attrs}
  end

  def _handle_call(:state, _from, attrs) do
    {:reply, {:ok, attrs.state}, attrs}
  end

  defp default_attrs do
    %{state: "start"}
  end
end
