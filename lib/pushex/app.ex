defmodule Pushex.App do
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Application.put_env(:vex, :sources, [Pushex.Validators, Vex.Validators])

    config = Pushex.Config.make_defaults(Application.get_all_env(:pushex))

    gcm_pool_options = Keyword.merge([
      name: {:local, Pushex.GCM},
      worker_module: Pushex.Worker,
    ], config[:gcm][:pool_options])

    apns_pool_options = Keyword.merge([
      name: {:local, Pushex.APNS},
      worker_module: Pushex.Worker,
    ], config[:apns][:pool_options])

    children = [
      worker(Pushex.Config, [config]),
      worker(GenEvent, [[name: Pushex.EventManager]]),
      supervisor(Pushex.Watcher, [Pushex.Config, :event_handlers, []]),
      :poolboy.child_spec(Pushex.GCM, gcm_pool_options, [client: Pushex.GCM.Client]),
      :poolboy.child_spec(Pushex.APNS, apns_pool_options, [client: Pushex.APNS.Client]),
      worker(Pushex.AppManager.Memory, []),
      worker(Pushex.APNS.SSLPoolManager, [])
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
