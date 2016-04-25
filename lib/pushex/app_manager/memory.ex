defmodule Pushex.AppManager.Memory do
  @moduledoc """
  An in memory implementation using a `GenServer` for `Pushex.AppManager`
  """
  use GenServer

  @behaviour Pushex.AppManager

  @valid_platforms ~w(gcm apns)a

  def start(apps \\ []) do
    GenServer.start(__MODULE__, apps, name: __MODULE__)
  end

  def start_link(apps \\ []) do
    GenServer.start_link(__MODULE__, apps, name: __MODULE__)
  end

  def init([]) do
    {:ok, Pushex.Config.get(:apps, [])}
  end
  def init(apps) do
    {:ok, apps}
  end

  def find_app(platform, name) when platform in unquote(@valid_platforms) do
    GenServer.call(__MODULE__, {:find, platform, name})
  end

  def handle_call({:find, platform, name}, _from, apps) do
    app = Map.get(apps[platform], name)
    {:reply, app, apps}
  end
end
