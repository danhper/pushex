defmodule Pushex.Case do
  use ExUnit.CaseTemplate

  setup do
    config = Application.get_all_env(:pushex)
    on_exit fn ->
      Pushex.Config.configure(config)
    end
  end
end
