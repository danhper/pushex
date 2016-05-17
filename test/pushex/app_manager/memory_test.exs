defmodule Pushex.AppManager.MemoryTest do
  use ExUnit.Case

  alias Pushex.AppManager

  test "find returns the requested app" do
    assert AppManager.Memory.find_app(:gcm, "default_app")
    refute AppManager.Memory.find_app(:gcm, "inexisting_app")
  end
end
