defmodule Pushex.GCM.Request do
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
    priority: atom,
    content_available: boolean,
    delay_while_idle: boolean,
    time_to_live: non_neg_integer,
    restricted_package_name: String.t,
    data: map,
    notification: map
  }

  @notification_valid_keys ~w(title body icon sound badge tag color click_action body_loc_key
                              body_loc_args title_loc_key title_loc_args)a

  validates :app,
    presence: true,
    type: [is: Pushex.GCM.App]
  validates :registration_ids,
    type: [is: [list: :binary], allow_nil: true],
    presence: [if: [to: nil]]
  validates :to,
    type: [is: :binary, allow_nil: true],
    presence: [if: [registration_ids: nil]]
  validates :collapse_key,
    type: [is: :binary, allow_nil: true]
  validates :priority,
    type: [is: :atom, allow_nil: true],
    inclusion: [in: ~w(high normal), allow_nil: true]
  validates :content_available,
    type: [is: :boolean, allow_nil: true]
  validates :delay_while_idle,
    type: [is: :boolean, allow_nil: true]
  validates :time_to_live,
    type: [is: :integer, allow_nil: true]
  validates :restricted_package_name,
    type: [is: :binary, allow_nil: true]
  validates :data,
    type: [is: :map, allow_nil: true]
  validates :notification,
    type: [is: :map, allow_nil: true],
    by: &__MODULE__.validate_notification/1


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

  @doc false
  def validate_notification(nil), do: :ok
  def validate_notification(notification) when is_map(notification) do
    extra_keys = Map.keys(notification) -- @notification_valid_keys
    if Enum.empty?(extra_keys),
      do: :ok,
      else: {:error, "got unknown keys #{inspect(extra_keys)} for notification"}
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
