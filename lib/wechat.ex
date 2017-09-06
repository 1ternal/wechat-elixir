defmodule Wechat do
  @moduledoc false

  defmodule ConfigMissingError do
    defexception message: """
      The app_id and app_secret is required.
      Please configure
      app_id and app_secret in your config.exs
      config :wechat, Wechat,
        app_id: YOUR_APP_ID
        app_secret: YOU_APP_SECRET
    """
  end

  alias Wechat.Workers.AccessToken
  alias Wechat.Workers.JSAPITicket

  def config do
    Keyword.merge(default_config(), app_config())
  end

  defp app_config do
    with conf when is_list(conf) <- Application.get_env(:wechat, Wechat),
         true                    <- Keyword.has_key?(conf, :appid),
         true                    <- Keyword.has_key?(conf, :secret)
    do
      conf
    else
      _ -> raise ConfigMissingError
    end
  end

  def appid do
    config()[:appid] |> get_env
  end

  def secret do
    config()[:secret] |> get_env
  end

  def token do
    config()[:token] |> get_env
  end

  def encoding_aes_key do
    config()[:encoding_aes_key] |> get_env
  end

  defp default_config do
    [
      api_host: "https://api.weixin.qq.com/cgi-bin",
      mp_host: "https://mp.weixin.qq.com/cgi-bin"
    ]
  end

  defp get_env({:system, env_var}) do
    System.get_env(env_var)
  end
  defp get_env(val) do
    val
  end

  defdelegate access_token, to: AccessToken, as: :get
  defdelegate jsapi_ticket, to: JSAPITicket, as: :get
end
