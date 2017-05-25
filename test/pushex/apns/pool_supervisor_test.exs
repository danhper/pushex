defmodule Pushex.APNS.PoolSupervisorTest do
  use ExUnit.Case

  alias Pushex.APNS.PoolSupervisor
  alias Pushex.APNS.App

  setup do
    app = App.create!(%{name: "pushex", env: :prod, pem: "foo", team_id: "bar", key_identifier: "baz"})
    {:ok, %{app: app}}
  end

  test "get_pool_name", %{app: app} do
    assert PoolSupervisor.get_pool_name(app) == :"apns_pool:pushex"
  end

  test "ensure_pool_started", %{app: app} do
    {:ok, pid} = PoolSupervisor.ensure_pool_started(app)
    assert %{active: 1} = Supervisor.count_children(PoolSupervisor)
    assert {:ok, ^pid} = PoolSupervisor.ensure_pool_started(app)
    assert %{active: 1} = Supervisor.count_children(PoolSupervisor)
  end
end
