defmodule Pushex.App do
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # temporary workaround
    unless Application.get_env(:apns, :pools) do
      Application.put_env(:apns, :pools, [])
    end
    Application.ensure_all_started(:apns)

    config = Application.get_all_env(:pushex)

    children = [
      worker(Pushex.Config, [config]),
      worker(GenEvent, [[name: Pushex.EventManager]]),
      supervisor(Pushex.Watcher, [Pushex.Config, :event_handlers, []]),
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
end
