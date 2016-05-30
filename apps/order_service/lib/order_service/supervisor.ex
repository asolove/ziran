defmodule OrderService.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def get(supervisor, id) do
    Supervisor.start_child(supervisor, [id])
  end

  def init(:ok) do
    table = :ets.new(:order, [:set, :public])
    children = [
      worker(OrderService.Order, [%{table: table, trace: Trace}], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
