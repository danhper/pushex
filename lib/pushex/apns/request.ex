defmodule Pushex.APNS.Request do
  @moduledoc """
  `Pushex.APNS.Request` represents a request that will be sent to APNS.
  It contains the notification, and all the metadata that can be sent with it.

  Only the key with a value will be sent to APNS.
  """

  use Vex.Struct

  defstruct [:app, :to, :notification]

  @type t :: %__MODULE__{
    app: Pushex.APNS.App.t,
    to: String.t | [String.t],
    notification: map
  }

  validates :app, presence: true, type: [is: Pushex.APNS.App]
  validates :notification, type: [is: [:map, :nil]]
  validates :to, type: [is: [:binary, :nil, list: :binary]], presence: true

  def to_message(request) do
    message = APNS.Message.new
    Enum.reduce(request.notification, message, fn
      {_k, v}, msg when is_nil(v) or v == "" -> msg
      {k, v}, msg -> Map.put(msg, k, v)
    end)
  end
end
