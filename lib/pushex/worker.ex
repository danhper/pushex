defmodule Pushex.Worker do
  @moduledoc false

  use GenServer


  @doc false
  def init(init_arg) do
    {:ok, init_arg}
  end

  @doc false
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options)
  end

  @doc """
  Sends a notification asynchronously using the implementation defined in the configuration
  """
  @spec send_notification(Pushex.GCM.request | Pushex.APNS.request, reference) :: reference
  def send_notification(request, ref \\ make_ref())
  def send_notification(%Pushex.GCM.Request{} = request, ref) do
    do_send_notification_async(Pushex.GCM, request, ref)
  end
  def send_notification(%Pushex.APNS.Request{} = request, ref) do
    do_send_notification_async(Pushex.APNS, request, ref)
  end

  defp do_send_notification_async(module, request, ref) do
    message = {:send, {self(), ref}, request}
    :poolboy.transaction(module, &GenServer.cast(&1, message))
    ref
  end

  @doc false
  def handle_cast({:send, info, request}, state) do
    do_send_notification(state[:client], info, request)
    {:noreply, state}
  end

  defp do_send_notification(client, info, request) do
    Pushex.EventManager.handle_request(request, info)
    client.send_notification(request)
    |> Pushex.EventManager.handle_response(request, info)
  end
end
