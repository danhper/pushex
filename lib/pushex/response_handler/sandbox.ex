defmodule Pushex.EventHandler.Sandbox do
  @moduledoc """
  The event handler used when sandbox mode is activated.

  It will send a message containing the response, request and pid/ref information
  back to the caller of `Pushex.push/2` and record the notification
  to `Pushex.Sandbox`.
  """

  use Pushex.EventHandler

  def handle_event({:response, response, request, {pid, ref} = info}, state) do
    send(pid, {response, request, ref})
    Pushex.Sandbox.record_notification(response, request, info)
    {:ok, state}
  end
end
