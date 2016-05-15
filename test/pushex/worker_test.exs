defmodule Pushex.WorkerTest do
  use Pushex.Case

  alias Pushex.Worker
  alias Pushex.GCM

  test "send_notification returns a reference" do
    assert is_reference(Worker.send_notification(%GCM.Request{}))
  end

  test "send_notification calls handle_response" do
    ref = Worker.send_notification(%GCM.Request{})
    assert_receive {_, _, ^ref}
  end
end
