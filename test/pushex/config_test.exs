defmodule Pushex.ConfigTest do
  use Pushex.Case

  alias Pushex.Config

  setup do
    Application.put_env(:pushex, :event_handlers, [])
    Application.put_env(:pushex, :gcm, [])
  end

  test "defaults" do
    {:ok, []} = Config.init([])
    config = Application.get_all_env(:pushex)
    assert config[:gcm][:endpoint]
    assert config[:event_handlers]
  end

  test "make_defaults with sandbox" do
    {:ok, []} = Config.init(sandbox: true)
    config = Application.get_all_env(:pushex)
    assert config[:event_handlers] == [Pushex.EventHandler.Sandbox]
    assert config[:gcm][:client_impl] == Pushex.GCM.Client.Sandbox
  end

  test "make_defaults without sandbox" do
    {:ok, []} = Config.init(sandbox: false)
    config = Application.get_all_env(:pushex)
    assert config[:event_handlers] == []
    assert config[:gcm][:client_impl] == Pushex.GCM.Client.HTTP
  end

  test "load all apps" do
    {:ok, []} = Config.init(gcm: [apps: [[name: "default_app", auth_key: "whatever"]]])
    config = Application.get_all_env(:pushex)
    assert %{"default_app" => gcm_app} = config[:apps][:gcm]
    assert gcm_app.name == "default_app"
    assert gcm_app.auth_key == "whatever"
  end
end
