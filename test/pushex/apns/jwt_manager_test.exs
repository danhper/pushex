defmodule Pushex.APNS.JWTManagerTest do
  use ExUnit.Case

  alias Pushex.APNS.JWTManager

  @pemfile Path.expand("../../fixtures/dummy-jwt.pem", __DIR__)

  setup do
    {:ok, pid} = JWTManager.start_link(100, [])
    app1 = %Pushex.APNS.App{name: "app-1", team_id: "team-1", key_identifier: "key-1", pemfile: @pemfile}
    app2 = %Pushex.APNS.App{name: "app-2", team_id: "team-2", key_identifier: "key-2", pemfile: @pemfile}
    {:ok, jwt_manager: pid, app1: app1, app2: app2}
  end

  test "fetch_token generates a new token no token found", %{jwt_manager: jwt_manager, app1: app} do
    assert JWTManager.fetch_token(app, jwt_manager)
  end

  test "fetch_token caches existing tokens", %{jwt_manager: jwt_manager, app1: app} do
    token = JWTManager.fetch_token(app, jwt_manager)
    assert JWTManager.fetch_token(app, jwt_manager) == token
  end

  test "fetch_token invalidates tokens", %{jwt_manager: jwt_manager, app1: app} do
    token = JWTManager.fetch_token(app, jwt_manager)
    Process.sleep(101)
    assert JWTManager.fetch_token(app, jwt_manager) != token
  end

  test "fetch_token creates a token per app", %{jwt_manager: jwt_manager, app1: app1, app2: app2} do
    token1 = JWTManager.fetch_token(app1, jwt_manager)
    token2 = JWTManager.fetch_token(app2, jwt_manager)
    assert token1 != token2
  end
end
