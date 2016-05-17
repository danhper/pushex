defmodule Pushex.UtilTest do
  use ExUnit.Case

  alias Pushex.Util

  test "normalize_notification without platform key" do
    assert Util.normalize_notification(%{title: "foo"}, :apns) == %{title: "foo"}
  end

  test "normalize_notification with platform key" do
    map = %{title: "foo", apns: %{alert: "foobar", title: "other"}}
    assert Util.normalize_notification(map, :apns) == %{alert: "foobar", title: "other"}
  end
end
