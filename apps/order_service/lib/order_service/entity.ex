defmodule Entity do
  defmacro __using__(_) do
    quote location: :keep do
      use GenServer

      def start_link(opts, id) do
        GenServer.start_link(__MODULE__, Dict.put(opts, :id, id))
      end

      def init(%{:id => id, :table => table} =opts) do
        attrs = attributes(table, id)
        {:ok, {id, attrs, opts}}
      end

      def handle_call(call, from, {id, attrs, opts}) do
        response = _handle_call(call, from, attrs)
        new_attrs = get_attrs(response)

				if new_attrs != attrs do
          save(opts.table, opts.id, new_attrs)
        end

        state = {id, new_attrs, opts}
        update_state(response, state)
      end

      def _handle_call(call, from, state) do
        IO.puts("Fell through to default")
      end

      defoverridable [_handle_call: 3]

      defp save(table, id, attrs) do
        :ets.insert(table, {id, attrs})
      end

      defp attributes(table, id) do
        case :ets.lookup(table, id) do
          [{id, attrs}] -> attrs
          _ -> default_attrs
        end
      end

      defp get_attrs(resp) do
        case resp do
					{:reply, _, attrs}    -> attrs
          {:reply, _, attrs, _} -> attrs
          {:noreply, attrs}     -> attrs
          {:noreply, attrs, _}  -> attrs
          {:stop, _, _, attrs}  -> attrs
          {:stop, _, attrs}     -> attrs
        end
      end

      defp update_state(resp, state) do
        case resp do
					{:reply, a, _}    -> {:reply, a, state}
          {:reply, a, _, t} -> {:reply, a, state, t}
          {:noreply, _}     -> {:noreply, state}
          {:noreply, _, t}  -> {:noreply, state, t}
          {:stop, a, b, _}  -> {:stop, a, b, state}
          {:stop, a, _}     -> {:stop, a, state}
        end
      end
    end
  end
end
