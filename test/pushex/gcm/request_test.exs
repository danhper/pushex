defmodule Pushex.GCM.RequestTest do
  use ExUnit.Case

  alias Pushex.GCM.Request

  @app %Pushex.GCM.App{name: "foo", auth_key: "bar"}

  test "create from keyword" do
    assert {:ok, %Request{app: @app, to: "foo"}} = Request.create(app: @app, to: "foo")
  end

  test "create from dictionary" do
    assert {:ok, %Request{app: @app, to: "foo"}} = Request.create(%{app: @app, to: "foo"})
  end

  test "create from struct" do
    assert {:ok, %Request{app: @app, to: "foo"}} = Request.create(%Request{app: @app, to: "foo"})
  end

  test "create returns error on failure" do
    assert {:error, [{:error, :to, :type, "must be of type :binary"}]} = Request.create(app: @app, to: 1)
    assert {:error, _} = Request.create(app: @app, foo: "bar")
  end

  test "create! returns notification on success" do
    assert %Request{app: @app, to: "bar"} = Request.create!(app: @app, to: "bar")
  end

  test "create! raises on failure" do
    assert_raise Pushex.ValidationError, fn ->
      Request.create!(app: @app, to: 1)
    end
  end

  test "removes nil keys and app when encoding to JSON" do
    assert Poison.encode!(Request.create!(app: @app, to: "foo")) == Poison.encode!(%{to: "foo"})
  end
end
