defmodule Pushex.APNS.SSLPoolManagerTest do
  use Pushex.Case

  alias Pushex.APNS.SSLPoolManager

  setup do
    [{_, app}] = Application.get_env(:pushex, :apps)[:apns] |> Map.to_list
    Logger.configure(level: :info)
    on_exit fn ->
      Logger.configure(level: :debug)
    end
    {:ok, app: app}
  end

  test "ensure_pool_started", %{app: app} do
    refute SSLPoolManager.pool_started?(app.name)
    assert {:ok, _pid} =  SSLPoolManager.ensure_pool_started(app)
    assert SSLPoolManager.pool_started?(app.name)
  end
end
