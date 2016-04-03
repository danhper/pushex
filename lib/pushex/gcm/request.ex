defmodule Pushex.GCM.Request do
  @moduledoc """
  `Pushex.GCM.Request` represents a request that will be sent to GCM.
  It contains the notification, and all the metadata that can be sent with it.

  Only the key with a value will be sent to GCM, so that the proper default
  are used.
  """

  use Vex.Struct

  defstruct [
    :app,
    :registration_ids,
    :to,
    :collapse_key,
    :priority,
    :content_available,
    :delay_while_idle,
    :time_to_live,
    :restricted_package_name,
    :data,
    :notification
  ]

  @type t :: %__MODULE__{
    app: Pushex.GCM.App.t,
    registration_ids: [String.t],
    to: String.t,
    collapse_key: String.t,
    priority: String.t,
    content_available: boolean,
    delay_while_idle: boolean,
    time_to_live: non_neg_integer,
    restricted_package_name: String.t,
    data: map,
    notification: map
  }

  validates :app,
    presence: true,
    type: [is: Pushex.GCM.App]
  validates :registration_ids,
    type: [is: [[list: :binary], :nil]],
    presence: [if: [to: nil]]
  validates :to,
    type: [is: [:binary, :nil]],
    presence: [if: [registration_ids: nil]]
  validates :collapse_key,
    type: [is: [:binary, :nil]]
  validates :priority,
    type: [is: [:string, :nil]],
    inclusion: [in: ~w(high normal), allow_nil: true]
  validates :content_available,
    type: [is: [:boolean, :nil]]
  validates :delay_while_idle,
    type: [is: [:boolean, :nil]]
  validates :time_to_live,
    type: [is: [:integer, :nil]]
  validates :restricted_package_name,
    type: [is: [:binary, :nil]]
  validates :data,
    type: [is: [:map, :nil]]
  validates :notification,
    type: [is: [:map, :nil]]
    # by: &__MODULE__.validate_notification/1


  def validate(notification) do
    Vex.validate(notification)
  end

  def create!(params) do
    case create(params) do
      {:ok, notification} -> notification
      {:error, err}       -> raise Pushex.ValidationError, errors: err
    end
  end
  def create(%__MODULE__{} = notification) do
    validate(notification)
  end
  def create(params) when is_map(params) do
    struct(__MODULE__, params) |> create
  end
  def create(params) when is_list(params) do
    Enum.into(params, %{}) |> create
  end
end

defimpl Poison.Encoder, for: Pushex.GCM.Request do
  def encode(notification, options) do
    Map.from_struct(notification)
    |> Enum.filter(fn {_key, value} -> not is_nil(value) end)
    |> Enum.into(%{})
    |> Map.delete(:app)
    |> Poison.encode!(options)
  end
end
