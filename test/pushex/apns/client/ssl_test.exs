defmodule Pushex.APNS.Client.SSLTest do
  use Pushex.Case

  alias Pushex.APNS.Response
  alias Pushex.APNS.Client.SSL

  test "generate_response" do
    results = [:ok, :ok, {:error, :invalid}]
    assert  %Response{} = response = SSL.generate_response(results)
    assert response.success == 2
    assert response.failure == 1
    assert response.results == results
  end

  test "make_messages" do
    req = %Pushex.APNS.Request{to: "foo", notification: %{alert: "ok"}}
    assert [message] = SSL.make_messages(req)
    assert message.token == req.to
    assert message.alert == req.notification.alert
  end
end
