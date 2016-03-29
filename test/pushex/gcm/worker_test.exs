defmodule Pushex.GCM.WorkerTest do
  use ExUnit.Case

  alias Pushex.GCM.Worker

  test "send_notification returns a reference" do
    assert is_reference(Worker.send_notification(%Pushex.GCM.Request{}))
  end

  test "send_notification calls handle_response" do
    ref = Worker.send_notification(%Pushex.GCM.Request{})
    assert_receive {_, _, ^ref}
  end
end
