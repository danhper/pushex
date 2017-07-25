defmodule Pushex.WatcherTest do
  use Pushex.Case

  alias Pushex.GCM.{Request, Response}

  defmodule BadHandler do
    @behaviour :gen_event

    def init(args) do
      {:ok, args}
    end

    def handle_call(_request, state) do
      {:ok, state}
    end

    def handle_event({:response, _response, _request, {pid, ref}}, state) do
      send pid, {:bad_handler, ref}
      {:ok, state}
    end
  end

  test "restarts children" do
    assert {:ok, _pid} = Pushex.Watcher.watch(Pushex.EventManager, BadHandler, [])
    assert BadHandler in :gen_event.which_handlers(Pushex.EventManager)
    ref = make_ref()
    :gen_event.notify(Pushex.EventManager, {:response, %Response{}, %Request{}, {self(), ref}})
    assert_receive {:bad_handler, ^ref}
    # crash here
    Logger.remove_backend(Logger.Backends.Console)
    :gen_event.notify(Pushex.EventManager, {:request, %Request{}, {self(), ref}})
    # wait for supervisor to restart handler
    :timer.sleep(100)
    Logger.add_backend(Logger.Backends.Console)

    :gen_event.notify(Pushex.EventManager, {:response, %Response{}, %Request{}, {self(), ref}})
    assert_receive {:bad_handler, ^ref}

    assert :ok = Pushex.Watcher.unwatch(Pushex.EventManager, BadHandler)
    :gen_event.notify(Pushex.EventManager, {:response, %Response{}, %Request{}, {self(), ref}})
    refute_receive {:bad_handler, ^ref}
    refute BadHandler in :gen_event.which_handlers(Pushex.EventManager)
  end
end
