defmodule Pushex.ConfigTest do
  use Pushex.Case

  setup do
    Application.put_env(:pushex, :response_handlers, [])
    Application.put_env(:pushex, :gcm, [])
  end

  test "make_defaults" do
    Pushex.Config.make_defaults
    config = Application.get_all_env(:pushex)
    assert config[:gcm][:endpoint]
    assert config[:response_handlers]
  end

  test "make_defaults with sandbox" do
    Application.put_env(:pushex, :sandbox, true)
    Pushex.Config.make_defaults
    config = Application.get_all_env(:pushex)
    assert config[:response_handlers] == [Pushex.ResponseHandler.Sandbox]
    assert config[:gcm][:client_impl] == Pushex.GCM.Client.Sandbox
  end

  test "make_defaults without sandbox" do
    Application.put_env(:pushex, :sandbox, false)
    Pushex.Config.make_defaults
    config = Application.get_all_env(:pushex)
    assert config[:response_handlers] == []
    assert config[:gcm][:client_impl] == Pushex.GCM.Client.HTTP
  end
end
