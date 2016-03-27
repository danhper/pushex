defmodule Pushex.GCM.AppTest do
  use ExUnit.Case

  alias Pushex.GCM.App

  test "validate name and auth_key" do
    assert App.valid?(%App{name: "foo", auth_key: "bar"})
    refute App.valid?(%App{name: "foo"})
    refute App.valid?(%App{auth_key: "bar"})
  end
end
