defmodule PushexTest do
  use Pushex.Case

  test "send_notification/1 delegates to Helpers" do
    ref = Pushex.send_notification(%Pushex.GCM.Request{})
    assert [{_, _, {_, ^ref}}] = Pushex.Sandbox.wait_notifications
  end

  test "send_notification/2 delegates to Helpers" do
    ref = Pushex.send_notification(%{body: "foo"}, to: "whoever", using: :gcm)
    assert [{_, _, {_, ^ref}}] = Pushex.Sandbox.wait_notifications
  end

  test "add_event_handler adds a new handler" do
    defmodule NoopHandler do
      use Pushex.EventHandler
    end
    refute List.keyfind(Pushex.Config.event_handlers, NoopHandler, 1)
    Pushex.add_event_handler(NoopHandler)
    assert List.keyfind(Pushex.Config.event_handlers, NoopHandler, 1)
  end
end
