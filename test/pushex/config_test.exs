defmodule Pushex.ConfigTest do
  use Pushex.Case

  alias Pushex.Config

  setup do
    Config.set(:response_handlers, [])
    Config.set(:gcm, [])
  end

  test "defaults" do
    {:ok, config} = Config.init([])
    assert config[:gcm][:endpoint]
    assert config[:response_handlers]
  end

  test "make_defaults with sandbox" do
    {:ok, config} = Config.init(sandbox: true)
    assert config[:response_handlers] == [Pushex.ResponseHandler.Sandbox]
    assert config[:gcm][:client_impl] == Pushex.GCM.Client.Sandbox
  end

  test "make_defaults without sandbox" do
    {:ok, config} = Config.init(sandbox: false)
    assert config[:response_handlers] == []
    assert config[:gcm][:client_impl] == Pushex.GCM.Client.HTTP
  end

  test "load all apps" do
    {:ok, config} = Config.init(gcm: [apps: [[name: "default_app", auth_key: "whatever"]]])
    assert %{"default_app" => gcm_app} = config[:apps][:gcm]
    assert gcm_app.name == "default_app"
    assert gcm_app.auth_key == "whatever"
  end

  test "get returns key or default" do
    assert Config.get(:sandbox)
    assert Config.get(:foobar, "ok") == "ok"
  end

  test "get_all returns the config" do
    assert (list when is_list(list)) = Config.get_all
  end

  test "set the config value " do
    refute Config.get(:foo)
    assert Config.set(:foo, :bar) == :ok
    assert Config.get(:foo) == :bar
  end
end
