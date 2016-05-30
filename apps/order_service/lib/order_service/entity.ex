defmodule Entity do
  defmacro __using__(_) do
    quote location: :keep do
      use GenServer

      def start_link(opts, id) do
        GenServer.start_link(__MODULE__, Dict.put(opts, :id, id))
      end

      def init(%{:id => id, :table => table} =opts) do
        {:ok, {id, load(table, id), opts}}
      end

      # Wrap GenServer calls to add magic
      #  - tracing
      #  - persistence & version management

      def handle_call(call, from, {id, attrs, opts}) do
        response = _handle_call(call, from, attrs)
        new_attrs = get_state_from_call_response(response)

				if new_attrs != attrs do
          save(opts.table, opts.id, new_attrs)
          if Map.get(opts, :trace) do
            entity = {__MODULE__, opts.id}
            action = {{from, call}, new_attrs}
            OrderService.Trace.action(opts.trace, entity, action)
          end
        end

        state = {id, new_attrs, opts}
        update_state_in_call_response(response, state)
      end

      def _handle_call(call, from, state) do
        IO.puts("Fell through to default")
      end

      defoverridable [_handle_call: 3]

      # Persistence

      defp save(table, id, attrs) do
        :ets.insert(table, {id, attrs})
      end

      defp load(table, id) do
        case :ets.lookup(table, id) do
          [{id, attrs}] -> attrs
          _ -> default_attrs
        end
      end

      # Handling gen_server responses

      defp get_state_from_call_response(resp) do
        case resp do
					{:reply, _, attrs}    -> attrs
          {:reply, _, attrs, _} -> attrs
          {:noreply, attrs}     -> attrs
          {:noreply, attrs, _}  -> attrs
          {:stop, _, _, attrs}  -> attrs
          {:stop, _, attrs}     -> attrs
        end
      end

      defp update_state_in_call_response(resp, state) do
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
