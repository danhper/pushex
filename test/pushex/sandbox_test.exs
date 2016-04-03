defmodule Pushex.SandboxTest do
  use Pushex.Case

  alias Pushex.Sandbox

  test "record_notification records a notification" do
    ref = make_ref()
    Sandbox.record_notification(%{}, %{}, {self(), ref})
    assert [{_, _, {_, ^ref}}] = Sandbox.list_notifications
  end

  test "list_notifications accept pid" do
    ref = make_ref()
    parent = self()
    Sandbox.record_notification(%{}, %{}, {parent, ref})
    task = Task.async fn ->
      assert Sandbox.list_notifications == []
      assert [{_, _, {_, ^ref}}] = Sandbox.list_notifications(pid: parent)
      Sandbox.record_notification(%{}, %{}, {self(), make_ref()})
      assert [_] = Sandbox.list_notifications
    end
    Task.await(task)
    assert [{_, _, {_, ^ref}}] = Sandbox.list_notifications
  end

  test "wait_notifications waits before failing" do
    parent = self()
    ref = make_ref()
    Task.async fn ->
      :timer.sleep(50)
      Sandbox.record_notification(%{}, %{}, {parent, ref})
    end
    assert Sandbox.list_notifications == []
    assert [{_, _, {_, ^ref}}] = Sandbox.wait_notifications
  end

  test "clear_notifications accepts pid" do
    ref = make_ref()
    parent = self()
    Sandbox.record_notification(%{}, %{}, {parent, ref})
    task = Task.async fn ->
      Sandbox.record_notification(%{}, %{}, {self(), make_ref()})
      assert [_] = Sandbox.list_notifications
      Sandbox.clear_notifications
      assert Sandbox.list_notifications == []
    end
    Task.await(task)
    assert [{_, _, {_, ^ref}}] = Sandbox.list_notifications
  end
end
