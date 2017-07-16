defmodule Pushex.APNS.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    apns_config = Application.get_env(:pushex, :apns)

    apns_pool_options = Keyword.merge([
      name: {:local, Pushex.APNS},
      worker_module: Pushex.Worker,
    ], apns_config[:pool_options])

    children = [
      supervisor(Pushex.APNS.PoolSupervisor, []),
      worker(Pushex.APNS.JWTManager, [[name: Pushex.APNS.JWTManager]]),
      :poolboy.child_spec(Pushex.APNS, apns_pool_options, [client: Pushex.APNS.Client]),
      worker(Pushex.APNS.SSLPoolManager, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
