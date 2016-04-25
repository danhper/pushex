defmodule Pushex.Case do
  use ExUnit.CaseTemplate

  setup do
    config = Pushex.Config.get_all
    on_exit fn ->
      Enum.each(config, fn {k, v} -> Pushex.Config.set(k, v) end)
    end
  end
end
