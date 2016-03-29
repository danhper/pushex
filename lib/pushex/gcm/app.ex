defmodule Pushex.GCM.App do
  use Vex.Struct

  defstruct [:name, :auth_key]

  @type t :: %__MODULE__{name: String.t, auth_key: String.t}

  validates :name,
    presence: true,
    type: [is: :string]
  validates :auth_key,
    presence: true,
    type: [is: :string]
end
