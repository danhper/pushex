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
  def send_notification(request, ref \\ make_ref) do
    GenServer.cast(__MODULE__, {:send, {self, ref}, request})
    ref
  end

  @doc false
  def handle_cast({:send, {pid, ref}, request}, state) do
    Pushex.GCM.Client.send_notification(request)
    |> Pushex.ResponseHandler.handle_response(request, {pid, ref})
    {:noreply, state}
  end
end
