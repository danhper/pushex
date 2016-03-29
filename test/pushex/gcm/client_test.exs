defmodule Pushex.GCM.ClientTest do
  use ExUnit.Case

  alias Pushex.GCM.Request

  test "send_notification delegates to impl" do
    assert {:ok, _} = Pushex.GCM.Client.send_notification(%Request{to: "foo"})
    assert {:error, _} = Pushex.GCM.Client.send_notification(%Request{to: :bad_id})
  end
end
