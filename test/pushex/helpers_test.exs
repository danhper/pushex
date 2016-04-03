defmodule Pushex.HelpersTest do
  use Pushex.Case

  alias Pushex.Helpers
  alias Pushex.GCM

  test "send_notification delegates to GCM when using: :gcm" do
    ref = Helpers.send_notification(%{body: "foo"}, to: "whoever", using: :gcm, with_app: "default_app")
    assert_receive {{:ok, res}, req, ^ref}
    assert match?(%GCM.Request{}, req)
    assert match?(%GCM.Response{}, res)
    assert [{_, req, {_, ^ref}}] = Pushex.Sandbox.list_notifications
    assert req.notification.body == "foo"
  end

  test "allows to pass platform as string" do
    ref = Helpers.send_notification(%{}, to: "whoever", using: "gcm", with_app: "default_app")
    assert_receive {{:ok, res}, req, ^ref}
    assert match?(%GCM.Response{}, res)
    assert [{_, _, {_, ^ref}}] = Pushex.Sandbox.list_notifications
  end

  test "allows to pass list to :to" do
    ref = Helpers.send_notification(%{}, to: ["whoever"], using: "gcm", with_app: "default_app")
    assert_receive {{:ok, res}, req, ^ref}
    assert match?(%GCM.Response{}, res)
    assert [{_, _, {_, ^ref}}] = Pushex.Sandbox.list_notifications
  end

  test "send_notification delegates to GCM when passing a GCM request" do
    ref = Helpers.send_notification(%GCM.Request{})
    assert_receive {{:ok, res}, _, ^ref}
    assert match?(%GCM.Response{}, res)
    assert [{_, _, {_, ^ref}}] = Pushex.Sandbox.list_notifications
  end

  test "send_notification delegates to GCM when :with_app is a GCM app" do
    ref = Helpers.send_notification(%{}, to: "whoever", with_app: %GCM.App{})
    assert [{{:ok, res} , _, {_, ^ref}}] = Pushex.Sandbox.wait_notifications
    assert match?(%GCM.Response{}, res)
  end

  test "send_notification sends multiple notifications" do
    refs = Enum.map (1..10), fn _ ->
      Helpers.send_notification(%{}, to: "whoever", with_app: %GCM.App{})
    end
    assert (list when length(list) == 10) = Pushex.Sandbox.wait_notifications(count: 10)
    Enum.each list, fn {_, _, {_, ref}} ->
      assert Enum.find(refs, &(&1 == ref))
    end
  end

  test "send_notification raises when neither with_app nor :using is passed" do
    assert_raise ArgumentError, fn -> Helpers.send_notification(%{}) end
  end

  test "send_notification raises when :with_app is binary and :using is not passed" do
    assert_raise ArgumentError, fn -> Helpers.send_notification(%{}, with_app: "foo") end
  end

  test "send_notification gives a proper error message when platform does not exist" do
    assert_raise ArgumentError, ~s("foo" is not a valid platform), fn ->
      Helpers.send_notification(%{}, with_app: "foo", using: "foo")
    end
  end
end
