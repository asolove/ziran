defmodule OrderService do
  use Application

  def start(_type, _args) do
    OrderService.Supervisor.start_link
    OrderService.Trace.start_link
  end
end
