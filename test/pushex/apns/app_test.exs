defmodule Pushex.APNS.AppTest do
  use ExUnit.Case

  alias Pushex.APNS.App

  test "use_jwt?" do
    assert App.use_jwt?(%App{pem: "foo", team_id: "bar", key_identifier: "baz"})
    assert App.use_jwt?(%App{pemfile: "foo", team_id: "bar", key_identifier: "baz"})
    refute App.use_jwt?(%App{team_id: "bar", key_identifier: "baz"})
    refute App.use_jwt?(%App{pemfile: "foo", key_identifier: "baz"})
    refute App.use_jwt?(%App{pem: "foo", team_id: "bar"})
  end

  test "use_ssl_cert?" do
    assert App.use_ssl_cert?(%App{cert: "foo", key: "bar"})
    assert App.use_ssl_cert?(%App{certfile: "foo", key: "bar"})
    assert App.use_ssl_cert?(%App{cert: "foo", keyfile: "bar"})
    assert App.use_ssl_cert?(%App{certfile: "foo", keyfile: "bar"})
    refute App.use_ssl_cert?(%App{keyfile: "bar"})
    refute App.use_ssl_cert?(%App{cert: "bar"})
  end

  test "can_authenticate?" do
    assert App.can_authenticate?(%App{cert: "foo", key: "bar"})
    assert App.can_authenticate?(%App{pem: "foo", team_id: "bar", key_identifier: "baz"})
    refute App.can_authenticate?(%App{cert: "bar"})
    refute App.can_authenticate?(%App{pem: "foo", team_id: "bar"})
  end
end
