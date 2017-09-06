if Code.ensure_loaded?(Plug) do
  defmodule Wechat.Plugs.CheckUrlSignature do
    @moduledoc """
    Plug to check url signature.
    """

    import Plug.Conn
    alias Wechat.Utils.Signature

    def init(_opts) do
      [token: Wechat.token]
    end

    def call(%Plug.Conn{params: %{"timestamp" => timestamp, "nonce" => nonce, "signature" => signature}} = conn, [token: token]) do
      assign(conn, :url_checked, Signature.valid?(signature, [token, timestamp, nonce]))
    end
    def call(conn, _opt), do: assign(conn, :url_checked, :false)
  end
end
