defmodule Pushex.GCM.App do
  use Vex.Struct

  defstruct [
    :name,
    :auth_key
  ]

  validates :name,
    presence: true,
    type: [is: :string]
  validates :auth_key,
    presence: true,
    type: [is: :string]
end
