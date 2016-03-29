defmodule Pushex.UtilsTest do
  use ExUnit.Case

  setup do
    config = Application.get_all_env(:pushex)
    on_exit fn ->
      Enum.each(config, fn {k, v} -> Application.put_env(:pushex, k, v) end)
    end
  end

  test "load_apps_from_config load all apps" do
    apps = Pushex.Utils.load_apps_from_config
    assert %{"default_app" => app} = apps[:gcm]
    assert app.name == "default_app"
    assert app.auth_key == "whatever"
  end

  test "load_apps_from_config raises on bad config" do
    Application.put_env(:pushex, :gcm, apps: [[name: "foo"]])
    assert_raise Pushex.ValidationError, fn ->
      Pushex.Utils.load_apps_from_config
    end
  end
end