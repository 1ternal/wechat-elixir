defmodule Wechat.UtilsTest do
  use ExUnit.Case, async: true

  alias Wechat.Utils

  describe "Wechat.Utils.Cipher" do
    @encoding_aes_key "pISncqVLksFHfQiq5QnrYSmScE50r9PnBkBwDxvUUzP"
    @encrypted_message "PC22Yj5xCwJ6hxsbUWob3ScH1MOl/fSNRGvQDSUZltfnmLdgRDp1qghBL9yAXDpv2sK6YKQqdG03gMNKeKAOrhi16wVpmZ87v0zjK3eFIdcObMCs8IzMUyfU//AZbsR8352zJ7BKZ9uK/1i9PgBY1KFW0El71zUzNaPSH96GBbAuZTlOejMDauHjf1KVuYDAOZpYlrU4JOBxsbr/QBHuH44qcGBKkj2+IKcIAmSJ0J0Y6S1tmdd6gl2Y0KKoHhZP148vCUbrQ2fI7CZv/bWlEto3fQ22EGi9/piwmSdsAtseOmEGVjzCoAc//zY8VPm8HcCQ39MYPvy1CEtsFzkvP0by+A8ADwFWAvXHKdhKlejQsWGWFzrBw2DFekMDncz3bNjmU++QBKOkPcdisciaYEQxe1Qbjc7S2tXENXC9SQfpSegjc4Fb4iNxlTtWvutFQH9kWnLz4pO0ynnF/bjWKw=="

    test "#encrypt and #decrypt" do
      {_, plain} = Utils.Cipher.decrypt(@encrypted_message, @encoding_aes_key)
      content = plain |> Utils.MsgParser.parse |> Map.get("Content")
      assert content == "helloworld"
    end

    test "#encrypt" do
      {_, orig} = Utils.Cipher.decrypt(@encrypted_message, @encoding_aes_key)
      result = Utils.Cipher.encrypt(orig, @encoding_aes_key)
      {_, decrypted} = Utils.Cipher.decrypt(result, @encoding_aes_key)
      assert decrypted == orig
    end
  end

  describe "Wechat.Utils.MsgParser" do
    test "#parse" do
      xml_content =
        "../../fixture/utils_assets/messages.xml"
        |> Path.expand(__DIR__)
        |> File.read!

      available_keys = ~w(FromUserName
                          ToUserName
                          MsgType
                          CreateTime
                          MsgId
                          Content
                          MediaId
                          PicUrl
                          Format
                          Recognition
                          ThumbMediaId
                          Location_X
                          Location_Y
                          Scale
                          Label
                          Title
                          Description
                          Url)

      result = Wechat.Utils.MsgParser.parse(xml_content)

      for k <- Map.keys(result) do
        assert k in available_keys
      end
    end
  end
end
