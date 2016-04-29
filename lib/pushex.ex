defmodule Pushex do
  @moduledoc """
  Facade module to access Pushex functionalities.

  See Pushex.Helpers documentation for more information.
  """

  defdelegate send_notification(notification), to: Pushex.Helpers
  defdelegate send_notification(notification, opts), to: Pushex.Helpers
end
