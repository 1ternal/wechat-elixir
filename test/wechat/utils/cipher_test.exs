defmodule Wechat.Utils.CipherTest do
  use ExUnit.Case, async: true

  alias Wechat.Utils.{Cipher, MsgParser}

  @encoding_aes_key Wechat.encoding_aes_key()
  @token            Wechat.token()
  @encrypted_message "PC22Yj5xCwJ6hxsbUWob3ScH1MOl/fSNRGvQDSUZltfnmLdgRDp1qghBL9yAXDpv2sK6YKQqdG03gMNKeKAOrhi16wVpmZ87v0zjK3eFIdcObMCs8IzMUyfU//AZbsR8352zJ7BKZ9uK/1i9PgBY1KFW0El71zUzNaPSH96GBbAuZTlOejMDauHjf1KVuYDAOZpYlrU4JOBxsbr/QBHuH44qcGBKkj2+IKcIAmSJ0J0Y6S1tmdd6gl2Y0KKoHhZP148vCUbrQ2fI7CZv/bWlEto3fQ22EGi9/piwmSdsAtseOmEGVjzCoAc//zY8VPm8HcCQ39MYPvy1CEtsFzkvP0by+A8ADwFWAvXHKdhKlejQsWGWFzrBw2DFekMDncz3bNjmU++QBKOkPcdisciaYEQxe1Qbjc7S2tXENXC9SQfpSegjc4Fb4iNxlTtWvutFQH9kWnLz4pO0ynnF/bjWKw=="

  test "#encrypt and #decrypt" do
    {_, plain} = Cipher.decrypt(@encrypted_message, @encoding_aes_key)
    content = plain |> MsgParser.parse |> Map.get(:content)
    assert content == "helloworld"
  end

  test "#encrypt" do
    {_, orig} = Cipher.decrypt(@encrypted_message, @encoding_aes_key)
    result = Cipher.encrypt(orig, @encoding_aes_key)
    {_, decrypted} = Cipher.decrypt(result, @encoding_aes_key)
    assert decrypted == orig
  end

  test "#ecnrypt_message" do
    reply = %{
      "ToUserName"   => "toUser",
      "FromUserName" => "fromUser",
      "CreateTime"   => "12345678",
      "MsgType"      => "text",
      "Content"      => "你好",
    }

    result = Cipher.encrypt_message(reply, @encoding_aes_key, @token)
    assert Map.has_key?(result, "Encrypt")
    assert Map.has_key?(result, "MsgSignature")
    assert Map.has_key?(result, "Nonce")
    assert Map.has_key?(result, "TimeStamp")
  end
end
