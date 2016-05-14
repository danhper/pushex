defmodule Pushex.APNS.Client do
  @moduledoc """
  Module defining the behaviour to send requests to APNS..

  The behaviour can be changed by setting the `:client_impl` module
  under the configuration `pushex: :apns` key
  """

  @callback send_notification(app :: atom, message :: APNS.Message.t) :: :ok

  def send_notification(request) do
    tokens = List.wrap(request.to)
    base_message = Pushex.APNS.Request.to_message(request)
    Enum.each tokens, fn token ->
      message = Map.put(base_message, :token, token)
      impl.send_notification(request.app, message)
    end
  end

  defp impl, do: Application.get_env(:pushex, :apns)[:client_impl]
end
