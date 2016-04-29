defmodule Pushex do
  @moduledoc """
  Facade module to access Pushex functionalities.

  See Pushex.Helpers documentation for more information.
  """

  defdelegate send_notification(notification), to: Pushex.Helpers
  defdelegate send_notification(notification, opts), to: Pushex.Helpers

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
