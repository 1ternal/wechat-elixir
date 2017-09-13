defmodule Wechat.Utils.Cipher do
  @moduledoc """
  Encrypt and Decrypt wechat msg.
  """
  alias Wechat.Utils.MsgParser

  def encrypt_message(reply, encoding_ase_key, token) do
    message          = encrypt(MsgParser.build_xml(reply), encoding_ase_key)

    timestamp = System.system_time(:seconds)
    nonce     = Base.encode16(:crypto.strong_rand_bytes(5), case: :lower)
    signature = Wechat.Utils.Signature.sign([token, timestamp, nonce, message])

    %{
      "Encrypt"      => message,
      "MsgSignature" => signature,
      "TimeStamp"    => timestamp,
      "Nonce"        => nonce,
    }
  end

  @aes_block_size 32
  def encrypt(plain_data, encoding_aes_key) do
    aes_key = decode_key!(encoding_aes_key)
    plain_data
    |> combine
    |> pad(@aes_block_size)
    |> do_encrpyt(aes_key)
    |> Base.encode64
  end

  def decrypt(msg_encrypt, encoding_aes_key) do
    aes_key = decode_key!(encoding_aes_key)
    msg_encrypt
    |> Base.decode64!
    |> do_descrypt(aes_key)
    |> unpad
    |> split
  end

  defp do_encrpyt(data, aes_key) do
    :crypto.block_encrypt(:aes_cbc, aes_key, iv_from_aes_key(aes_key), data)
  end

  defp do_descrypt(data, aes_key) do
    :crypto.block_decrypt(:aes_cbc, aes_key, iv_from_aes_key(aes_key), data)
  end

  # random(16B) + msg_len(4B) + msg + appid
  defp combine(data) do
    :crypto.strong_rand_bytes(16) <>
    <<String.length(data)::integer-size(32)>> <>
    data <>
    Wechat.appid
  end

  defp split(<<_rand_bytes :: binary-size(16),
              msg_len :: integer-size(32),
              msg :: binary-size(msg_len),
              appid :: binary>>) do
    {appid, msg}
  end

  defp iv_from_aes_key(aes_key) do
    binary_part(aes_key, 0, 16)
  end

  defp pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> to_string(:string.chars(to_add, to_add))
  end

  defp unpad(data) do
    to_remove = :binary.last(data)
    binary_part(data, 0, byte_size(data) - to_remove)
  end

  defp decode_key!(encoding_aes_key) do
    Base.decode64!(encoding_aes_key <> "=")
  end
end
