defmodule Pushex.EventHandlerTest do
  use Pushex.Case

  test "use EventHandler adds default handle_event definitions" do
    defmodule DummyHandler do
      use Pushex.EventHandler
    end

    assert DummyHandler.handle_event({:request, nil, nil}, :state) == {:ok, :state}
    assert DummyHandler.handle_event({:response, nil, nil, nil}, :state) == {:ok, :state}
  end
end
