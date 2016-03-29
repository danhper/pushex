defmodule Pushex.AppManagerTest do
  use ExUnit.Case

  defmodule DummyAppManager do
    def find_app(_, _), do: "dummy"
  end

  test "app_manager delegates to impl" do
    Application.put_env(:pushex, :app_manager_impl, DummyAppManager)
    assert Pushex.AppManager.find_app(nil, nil) == "dummy"
  after
    Application.put_env(:pushex, :app_manager_impl, Pushex.AppManager.Memory)
  end
end
