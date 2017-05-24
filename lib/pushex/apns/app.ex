defmodule Pushex.APNS.App do
  @moduledoc """
  `Pushex.APNS.App` represents an APNS application.

  `:name` is a unique identifier used to find the application,
  `:certfile` is the certificate for the application, and `:env` is `:dev` or `:prod`.
  """

  use Vex.Struct

  @type t :: %__MODULE__{name: String.t}

  @ssl_keys ~w(cert certfile cert_password key keyfile)a

  defstruct [
    :name,
    :env,
    :feedback_interval,
    :support_old_ios,
    :expiry,

    :cert,
    :certfile,
    :cert_password,
    :key,
    :keyfile,

    :pem,
    :pemfile,
    :team_id,
    :key_identifier
  ]

  validates :name,
    presence: true,
    type: [is: :string]

  validates :env,
    presence: true,
    inclusion: ~w(dev prod)a

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

  def can_authenticate?(%Pushex.APNS.App{} = app) do
    use_jwt?(app) or use_ssl_cert?(app)
  end

  def use_jwt?(%Pushex.APNS.App{team_id: tid, key_identifier: kid, pem: pem, pemfile: pemfile})
    when is_binary(tid) and is_binary(kid) and (is_binary(pem) or is_binary(pemfile)), do: true
  def use_jwt?(%Pushex.APNS.App{}), do: false

  def use_ssl_cert?(%Pushex.APNS.App{cert: cert, certfile: certfile, key: key, keyfile: keyfile})
    when (is_binary(cert) or is_binary(certfile)) and (is_binary(key) or is_binary(keyfile)), do: true
  def use_ssl_cert?(%Pushex.APNS.App{}), do: false

  def ssl_options(app) do
    app
    |> Map.from_struct()
    |> Map.take(@ssl_keys)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
  end
end
