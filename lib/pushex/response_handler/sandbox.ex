defmodule Pushex.ResponseHandler.Sandbox do
  @moduledoc """
  The response handler used when sandbox mode is activated.

  It will send a message containing the response, request and pid/ref information
  back to the caller of `Pushex.send_notification/2` and record the notification
  to `Pushex.Sandbox`.
  """

  @behaviour Pushex.ResponseHandler

  def handle_response(response, request, {pid, ref} = info) do
    send(pid, {response, request, ref})
    Pushex.Sandbox.record_notification(response, request, info)
  end
end
