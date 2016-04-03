defmodule Pushex.ExceptionsTest do
  use Pushex.Case

  test "Pushex.ValidationError" do
    errors = Vex.errors(%Pushex.GCM.Request{app: %Pushex.GCM.App{}, to: 1})
    exception = %Pushex.ValidationError{errors: errors}
    assert Exception.message(exception) == "error on :to with :type validator: must be of type :binary or nil"
  end

  test "Pushex.AppNotFoundError" do
    exception = %Pushex.AppNotFoundError{platform: :gcm, name: "dummy"}
    assert Exception.message(exception) == ~s(could not find an app named "dummy" for platform :gcm)
  end
end
