defmodule Pushex.APNS.SSLPoolManager do
  use GenServer

  alias Pushex.APNS.App

  @doc false
  def init(init_args) do
    {:ok, init_args}
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{pools: []}, name: __MODULE__)
  end

  def ensure_pool_started(app) do
    unless pool_started?(app.name) do
      start_pool(app)
    end
  end

  def pool_started?(name) do
    pools = GenServer.call(__MODULE__, :get_pools)
    not is_nil(List.keyfind(pools, name, 0))
  end

  def start_pool(app) do
    GenServer.call(__MODULE__, {:start_pool, app})
  end

  def handle_call(:get_pools, _from, state) do
    {:reply, state.pools, state}
  end

  def handle_call({:start_pool, app}, _from, state) do
    {res, new_state} = do_start_pool(app, state)
    {:reply, res, new_state}
  end

  defp do_start_pool(app, state) do
    case APNS.connect_pool(app.name, App.to_config(app)) do
      {:ok, pid} = res ->
        {res, %{state | pools: [{app.name, pid} | state.pools]}}
      error ->
        {error, state}
    end
  end
end
