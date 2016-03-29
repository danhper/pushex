defmodule Pushex.GCM.HelpersTest do
  use ExUnit.Case

  alias Pushex.GCM.Helpers
  alias Pushex.GCM.Request
  alias Pushex.GCM.App

  test "send_notification works with Request structs" do
    ref = Helpers.send_notification(%Request{})
    assert is_reference(ref)
    assert_receive {_, _, ^ref}
  end

  test "send_notification works with App structs" do
    app = %App{name: "foo", auth_key: "bar"}
    ref = Helpers.send_notification(%{}, to: "whoever", with_app: app)
    req = receive do
      {_, request, ^ref} -> request
    end
    assert req.app.name == app.name
  end

  test "send_notification works with app names" do
    app_name = "default_app"
    ref = Helpers.send_notification(%{}, to: "whoever", with_app: app_name)
    req = receive do
      {_, request, ^ref} -> request
    end
    assert req.app.name == app_name
  end

  test "send_notification works with default app" do
    ref = Helpers.send_notification(%{}, to: "whoever", using: :gcm)
    req = receive do
      {_, request, ^ref} -> request
    end
    assert req.app.name == Application.get_env(:pushex, :gcm)[:default_app]
  end

  test "send_notification raises when app do not exist" do
    assert_raise Pushex.AppNotFoundError, fn ->
      Helpers.send_notification(%{}, to: "whoever", with_app: "don't exist!")
    end
  end
end
