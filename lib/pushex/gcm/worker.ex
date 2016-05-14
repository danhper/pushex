defmodule Pushex.GCM.Worker do
  @moduledoc false

  use GenServer

  @doc false
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, [options], name: __MODULE__)
  end

  @doc """
  Sends a notification asynchronously using the implementation defined
  in the configuration
  """
  @spec send_notification(Pushex.GCM.Request.t, reference) :: reference
  def send_notification(request, ref \\ make_ref()) do
    message = {:send, {self(), ref}, request}
    GenServer.cast(__MODULE__, message)
    ref
  end

  @doc false
  def handle_cast({:send, info, request}, state) do
    do_send_notification(info, request)
    {:noreply, state}
  end

  defp do_send_notification(info, request) do
    Pushex.EventManager.handle_request(request, info)
    Pushex.GCM.Client.send_notification(request)
    |> Pushex.EventManager.handle_response(request, info)
  end
end
