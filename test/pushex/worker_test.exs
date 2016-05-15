defmodule Pushex.WorkerTest do
  use Pushex.Case

  test "send_notification returns a reference" do
    assert is_reference(Pushex.Worker.send_notification(%Pushex.GCM.Request{}))
    assert is_reference(Pushex.Worker.send_notification(%Pushex.APNS.Request{}))
  end

  test "send_notification with gcm calls handle_response" do
    ref = Pushex.Worker.send_notification(%Pushex.GCM.Request{})
    assert_receive {_, _, ^ref}
  end

  test "send_notification with apns calls handle_response" do
    ref = Pushex.Worker.send_notification(%Pushex.APNS.Request{})
    assert_receive {_, _, ^ref}
  end
end
