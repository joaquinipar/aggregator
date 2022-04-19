defmodule Aggregator.WebSocketHandler do
  @behaviour :cowboy_websocket

  require Logger

  def init(request, _state) do
    state = %{registry_key: :websocket_registry_key}

    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Registry.Aggregator
    |> Registry.register(state.registry_key, {})

    stories_json =
      Aggregator.Stories.get_stories()
      |> Poison.encode!

    # Sending top stories to the new subscriber.
    Process.send(self(), stories_json, [])

    {:ok, state}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  def websocket_handle({:text, _json}, state) do
    {:reply, {:text, "I got that message!"}, state}
  end

  def send_to_ws_suscribers(content) do
    message_json = Poison.encode!(content)

    Registry.dispatch(
      Registry.Aggregator,
      :websocket_registry_key,
      fn suscribers ->
        Logger.info("Sending the top stories to #{length(suscribers)} suscriber/s!")
        # Sending updated top stories
        suscribers
        |> Enum.map(fn {pid, _} -> Process.send(pid, message_json, []) end)
      end
    )
  end

end
