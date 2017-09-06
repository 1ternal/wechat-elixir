defmodule Wechat.Plugs.CheckUrlSignatureTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Wechat.Plugs.CheckUrlSignature

  @token Wechat.token()
  @valid_params %{
    "echostr"   => "16764560547512117162",
    "nonce"     => "494480818",
    "signature" => "424e39a9105370d04b2ff2727569dd3adaa6ff44",
    "timestamp" => "1504756650",
  }

  test "#init" do
    [token: token] = CheckUrlSignature.init([token: "fake token"])
    assert token == @token
  end

  test "#call with valid params" do
    conn = conn("GET", "/", @valid_params)
    conn = CheckUrlSignature.call(conn, [token: @token])
    assert conn.assigns[:url_checked]
  end

  test "#call with invalid params" do
    invalid = Map.update!(@valid_params, "signature", & &1 <> "0")
    conn = conn("GET", "/", invalid)
    conn = CheckUrlSignature.call(conn, [token: @token])
    refute conn.assigns[:url_checked]
  end
end
