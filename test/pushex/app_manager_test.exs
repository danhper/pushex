defmodule Pushex.AppManagerTest do
  use Pushex.Case

  defmodule DummyAppManager do
    def find_app(_, _), do: "dummy"
  end

  test "app_manager delegates to impl" do
    Pushex.Config.set(:app_manager_impl, DummyAppManager)
    assert Pushex.AppManager.find_app(nil, nil) == "dummy"
  end
end
