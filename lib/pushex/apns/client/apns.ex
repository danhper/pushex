defmodule Pushex.APNS.Client.SSL do
  @moduledoc false

  @behaviour Pushex.APNS.Client

  def send_notification(app, message) do
    APNS.push app.name, message
  end
end
