defmodule Pushex.GCM.ExceptionsTest do
  use Pushex.Case

  test "Pushex.GCM.HTTPError" do
    exception = %Pushex.GCM.HTTPError{status_code: 401, reason: "not authorized"}
    assert Exception.message(exception) == ~s(HTTP request failed with status 401: "not authorized")
  end
end
