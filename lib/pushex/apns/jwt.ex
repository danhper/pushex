defmodule Pushex.APNS.JWT do
  import Joken

  def generate_token(%Pushex.APNS.App{team_id: team_id, key_identifier: kid} = app) do
    %{"iat" => iat(), "iss" => team_id}
    |> token()
    |> with_header_arg("kid", kid)
    |> sign(es256(secret(app)))
    |> get_compact()
  end

  defp secret(%Pushex.APNS.App{pem: pem}) when is_binary(pem) do
    JOSE.JWK.from_pem(pem)
  end
  defp secret(%Pushex.APNS.App{pemfile: pemfile}) when is_binary(pemfile) do
    JOSE.JWK.from_pem_file(pemfile)
  end

  defp iat() do
    DateTime.to_unix(DateTime.utc_now(), :seconds)
  end
end
