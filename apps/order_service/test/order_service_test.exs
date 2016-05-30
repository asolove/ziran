defmodule OrderServiceTest do
  use ExUnit.Case
  doctest OrderService

  test "getting and updating order" do
    {:ok, sup} = OrderService.Supervisor.start_link
    {:ok, order} = OrderService.Supervisor.get(sup, 10)
    {:ok, "start"} = OrderService.Order.state(order)

    :ok = OrderService.Order.purchase(order)
    {:ok, "purchased"} = OrderService.Order.state(order)
    {:ok, order} = OrderService.Supervisor.get(sup, 10)
    {:ok, "purchased"} = OrderService.Order.state(order)

    :ok = OrderService.Order.cancel(order)
    {:ok, "canceled"} = OrderService.Order.state(order)
    {:ok, order} = OrderService.Supervisor.get(sup, 10)
    {:ok, "canceled"} = OrderService.Order.state(order)
  end
end
