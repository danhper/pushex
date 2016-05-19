defmodule Pushex.APNS.Request do
  @moduledoc """
  `Pushex.APNS.Request` represents a request that will be sent to APNS.
  It contains the notification, and all the metadata that can be sent with it.

  Only the key with a value will be sent to APNS.
  """

  use Vex.Struct

  defstruct [:app, :to, :notification]

  @valid_keys ~w(alert badge category content_available expiry extra generated_at id priority
                 retry_count sound support_old_ios token)

  @type t :: %__MODULE__{
    app: Pushex.APNS.App.t,
    to: String.t | [String.t],
    notification: map
  }

  validates :app, type: [is: Pushex.APNS.App]
  validates :notification, type: [is: :map]
  validates :to, type: [is: [:binary, [list: :binary]]]

  def create!(notification, app, opts) do
    params = %{notification: notification, app: app, to: opts[:to]}
    Pushex.Util.create_struct!(__MODULE__, params)
  end

  def to_message(request) do
    message = APNS.Message.new
    Enum.reduce(request.notification, message, fn
      {_k, v}, msg when is_nil(v) or v == "" -> msg
      {k, v}, msg -> Map.put(msg, to_atom(k), v)
    end)
  end

  defp to_atom(value) when value in unquote(@valid_keys), do: String.to_atom(value)
  defp to_atom(value), do: value
end
