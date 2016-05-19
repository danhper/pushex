defmodule Pushex.APNS.RequestTest do
  use Pushex.Case

  alias Pushex.APNS.{App, Request}

  test "to_message" do
    notif = %{alert: "notif", category: ""}
    assert %APNS.Message{} = message = Request.to_message(%Request{to: "foo", notification: notif})
    assert message.alert == "notif"
    refute message.category
  end

  test "to_message with string data" do
    assert %APNS.Message{} = message = Request.to_message(%Request{notification: %{"alert" => "notif"}})
    assert message.alert == "notif"
  end

  test "create!" do
    assert_raise Pushex.ValidationError, fn ->
      Request.create!(nil, nil, [])
    end
    assert %Request{} = Request.create!(%{alert: "notif"}, %App{}, to: "hello")
  end
end
