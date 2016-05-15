defmodule Pushex do
  @moduledoc """
  Facade module to access Pushex functionalities.

  See Pushex.Helpers documentation for more information.
  """

  defdelegate push(notification), to: Pushex.Helpers, as: :send_notification
  defdelegate push(notification, opts), to: Pushex.Helpers, as: :send_notification

  def add_event_handler(handler) do
    case Pushex.Watcher.watch(Pushex.EventManager, handler, []) do
      {:ok, _} = ok ->
        Pushex.Config.add_event_handler(handler)
        ok
      {:error, _reason} = err ->
        err
    end
  end
end
