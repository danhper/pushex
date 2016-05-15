defmodule Pushex.APNS.App do
  @moduledoc """
  `Pushex.APNS.App` represents an APNS application.

  `:name` is a unique identifier used to find the application,
  `:certfile` is the certificate for the application, and `:env` is `:dev` or `:prod`.
  """

  use Vex.Struct

  @type t :: %__MODULE__{name: String.t}

  defstruct [
    :name,
    :certfile,
    :env,
    :cert,
    :feedback_interval,
    :cert_password,
    :key,
    :keyfile,
    :support_old_ios,
    :expiry
  ]

  validates :name,
    presence: true,
    type: [is: :string]

  def create(app) do
    app = struct(Pushex.APNS.App, app)
    Pushex.Util.validate(app)
  end
  def create!(app) do
    case create(app) do
      {:ok, app} -> app
      {:error, errors} -> raise Pushex.ValidationError, errors: errors
    end
  end

  def to_config(app) do
    app
    |> Map.from_struct
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
  end
end
