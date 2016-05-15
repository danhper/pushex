defmodule Pushex.APNS.Helpers do
  @moduledoc false

  @doc """
  Sends a notification to APNS asynchrnously.
  """
  @spec send_notification(Pushex.APNS.Request.t | map, Keyword.t) :: reference
  def send_notification(request, opts \\ [])

  def send_notification(%Pushex.APNS.Request{} = request, _opts) do
    Pushex.Worker.send_notification(request)
  end
end
