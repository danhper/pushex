defmodule Pushex do
  @moduledoc """
  Facade module to access Pushex functionalities.

  See Pushex.Helpers documentation for more information.
  """

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    config = Application.get_all_env(:pushex)

    children = [
      worker(Pushex.Config, [config]),
      worker(Pushex.GCM.Worker, []),
      worker(Pushex.AppManager.Memory, [])
    ]

    children = children ++ (if config[:sandbox] do
      [worker(Pushex.Sandbox, [])]
    else
      []
    end)

    opts = [strategy: :one_for_one, name: Pushex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defdelegate send_notification(notification), to: Pushex.Helpers
  defdelegate send_notification(notification, opts), to: Pushex.Helpers
end
