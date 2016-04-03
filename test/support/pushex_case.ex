defmodule Pushex.Case do
  use ExUnit.CaseTemplate

  setup do
    config = Application.get_all_env(:pushex)
    on_exit fn ->
      Enum.each(config, fn {k, v} -> Application.put_env(:pushex, k, v) end)
    end
  end
end
