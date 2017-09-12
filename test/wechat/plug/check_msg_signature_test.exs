defmodule Wechat.Plugs.CheckMsgSignatureTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Wechat.Plugs.CheckMsgSignature

  @opts [
    appid:            Wechat.appid,
    token:            Wechat.token,
    encoding_aes_key: Wechat.encoding_aes_key,
  ]

  test "#init" do
    result = CheckMsgSignature.init([])
    for key <- ~W(appid token encoding_aes_key)a do
      assert Keyword.fetch!(result, key) == Keyword.fetch!(@opts, key)
    end
  end

  test "#call will bypass GET" do
    prev_conn = conn("GET", "/")
    conn = CheckMsgSignature.call(prev_conn, @opts)

    assert conn == prev_conn
    refute conn.assigns[:msg]
  end

  test "#call/2, POST with plain mode" do
    body = "../../../fixture/utils_assets/plain_message.xml" |> Path.expand(__DIR__) |> File.read!
    conn = build_conn(body)

    conn = CheckMsgSignature.call(conn, @opts)

    assert conn.assigns[:msg_type] == :plain
    message = conn.assigns[:msg]
    assert_message_body(message)
  end

  test "#call/2, POST with comp mode" do
    body = "../../../fixture/utils_assets/plain_message.xml" |> Path.expand(__DIR__) |> File.read!
    query_params = %{
      "encrypt_type"  => "aes",
      "msg_signature" => "ed1f7821f94fa0ea4fbf3106a8cf1b1ef5b50b10",
      "nonce"         => "1330840946",
      "signature"     => "dc9ad12d01548f03db2b9761c3a8854ad366e168",
      "timestamp"     => "1504763759"
    }
    conn = build_conn(body, query_params)

    conn = CheckMsgSignature.call(conn, @opts)

    assert conn.assigns[:msg_type] == :comp
    assert conn.assigns[:msg]
    message = conn.assigns[:msg]
    assert_message_body(message)
  end

  test "#call/2, POST with encrypted mode" do
    body = "../../../fixture/utils_assets/encrypted_message.xml" |> Path.expand(__DIR__) |> File.read!
    query_params = %{
      "encrypt_type"  => "aes",
      "msg_signature" => "ed1f7821f94fa0ea4fbf3106a8cf1b1ef5b50b10",
      "nonce"         => "1330840946",
      "signature"     => "dc9ad12d01548f03db2b9761c3a8854ad366e168",
      "timestamp"     => "1504763759"
    }

    conn = build_conn(body, query_params)
    conn = CheckMsgSignature.call(conn, @opts)

    assert conn.assigns[:msg_type] == :encrypt
    message = conn.assigns[:msg]
    assert_message_body(message)
  end

  defp assert_message_body(message) do
    assert Map.get(message, :content)
    assert Map.get(message, :create_time)
    assert Map.get(message, :from_user_name)
    assert Map.get(message, :msg_id)
    assert Map.get(message, :msg_type)
    assert Map.get(message, :to_user_name)
  end

  defp build_conn(body, params \\nil)
  defp build_conn(body, nil), do: conn("POST", "/", body)
  defp build_conn(body, params) do
    query_string =
      params
      |> Enum.map(& elem(&1, 0) <> "=" <> elem(&1, 1))
      |> Enum.join("&")

    "POST"
    |> conn("/wx?" <> query_string,  body)
    |> Plug.Conn.fetch_query_params
  end
end
