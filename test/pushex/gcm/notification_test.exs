defmodule Pushex.GCM.NotificationTest do
  use ExUnit.Case

  alias Pushex.GCM.Notification

  @app %Pushex.GCM.App{name: "foo", auth_key: "bar"}

  test "create from keyword" do
    assert {:ok, %Notification{app: @app, to: "foo"}} = Notification.create(app: @app, to: "foo")
  end

  test "create from dictionary" do
    assert {:ok, %Notification{app: @app, to: "foo"}} = Notification.create(%{app: @app, to: "foo"})
  end

  test "create from struct" do
    assert {:ok, %Notification{app: @app, to: "foo"}} = Notification.create(%Notification{app: @app, to: "foo"})
  end

  test "create returns error on failure" do
    assert {:error, [{:error, :to, :type, "must be of type :binary"}]} = Notification.create(app: @app, to: 1)
    assert {:error, _} = Notification.create(app: @app, foo: "bar")
  end

  test "create! returns notification on success" do
    assert %Notification{app: @app, to: "bar"} = Notification.create!(app: @app, to: "bar")
  end

  test "create! raises on failure" do
    assert_raise Pushex.ValidationError, fn ->
      Notification.create!(app: @app, to: 1)
    end
  end

  test "removes nil keys and app when encoding to JSON" do
    assert Poison.encode!(Notification.create!(app: @app, to: "foo")) == Poison.encode!(%{to: "foo"})
  end
end
