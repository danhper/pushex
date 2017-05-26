defmodule Pushex.Application do
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Application.put_env(:vex, :sources, [Pushex.Validators, Vex.Validators])
    Pushex.Supervisor.start_link()
  end
end
