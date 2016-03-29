defmodule Pushex.HelpersTest do
  use ExUnit.Case

  alias Pushex.Helpers
  alias Pushex.GCM

  test "send_notification delegates to GCM when using: :gcm" do
    ref = Helpers.send_notification(%{}, to: "whoever", using: :gcm, with_app: "default_app")
    {res, req} = receive do
      {{:ok, res}, req, ^ref} -> {res, req}
    end
    assert match?(%GCM.Request{}, req)
    assert match?(%GCM.Response{}, res)
  end

  test "send_notification delegates to GCM when passing a GCM request" do
    ref = Helpers.send_notification(%GCM.Request{})
    res = receive do
      {{:ok, res}, _, ^ref} -> res
    end
    assert match?(%GCM.Response{}, res)
  end

  test "send_notification delegates to GCM when :with_app is a GCM app" do
    ref = Helpers.send_notification(%{}, to: "whoever", with_app: %GCM.App{})
    res = receive do
      {{:ok, res}, _, ^ref} -> res
    end
    assert match?(%GCM.Response{}, res)
  end

  test "send_notification raises when neither with_app nor :using is passed" do
    assert_raise ArgumentError, fn -> Helpers.send_notification(%{}) end
  end

  test "send_notification raises when :with_app is binary and :using is not passed" do
    assert_raise ArgumentError, fn -> Helpers.send_notification(%{}, with_app: "foo") end
  end
end
