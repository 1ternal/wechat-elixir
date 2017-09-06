defmodule Wechat.Utils.MsgParser do
  @moduledoc """
  Parse wechat xml message.
  Generate a map structured message with plain xml.
  """

  require Logger

  @doc ~S"""
  parse xml doc using floki

  ## Example
      iex> Wechat.Utils.MsgParser()
          %{
            "ToUserName"   => "...",
            "FromUserName" => "...",
            "CreateTime"   => "...",
            "MsgType"      => "...",
            "MsgId"        => "...",
          }

  All messages type
  shared attrs
  <xml>
    <ToUserName><![CDATA[toUser]]></ToUserName>
    <FromUserName><![CDATA[fromUser]]></FromUserName>
    <CreateTime>1348831860</CreateTime>
    <MsgType><![CDATA[text]]></MsgType>
    <MsgId>1234567890123456</MsgId>
  </xml>

  Text
  <xml>
    <MsgType><![CDATA[text]]></MsgType>
    <Content><![CDATA[this is a test]]></Content>
  </xml>

  Picture
  <xml>
    <MsgType><![CDATA[image]]></MsgType>
    <PicUrl><![CDATA[this is a url]]></PicUrl>
    <MediaId><![CDATA[media_id]]></MediaId>
  </xml>

  Audio
  <xml>
    <MsgType><![CDATA[voice]]></MsgType>
    <MediaId><![CDATA[media_id]]></MediaId>
    <Format><![CDATA[Format]]></Format>
    <Recognition><![CDATA[腾讯微信团队]]></Recognition>
  </xml>

  Video
  <xml>
    <MsgType><![CDATA[video]]></MsgType>
    <MediaId><![CDATA[media_id]]></MediaId>
    <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
  </xml>

  Shortvideo
  <xml>
    <MsgType><![CDATA[shortvideo]]></MsgType>
    <MediaId><![CDATA[media_id]]></MediaId>
    <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
  </xml>

  Location
  <xml>
    <MsgType><![CDATA[location]]></MsgType>
    <Location_X>23.134521</Location_X>
    <Location_Y>113.358803</Location_Y>
    <Scale>20</Scale>
    <Label><![CDATA[位置信息]]></Label>
  </xml>

  Link
  <xml>
    <MsgType><![CDATA[link]]></MsgType>
    <Title><![CDATA[公众平台官网链接]]></Title>
    <Description><![CDATA[公众平台官网链接]]></Description>
    <Url><![CDATA[url]]></Url>
  </xml>

  Encrypted message
  <xml>
    <ToUserName></ToUserName>
    <Encrypt> </Encrypt>
  </xml>
  """

  def parse(xml) do
    [{"xml", [], attrs}] = Floki.find(xml, "xml")
    for {key, _, [value]} <- attrs, into: %{} do
      {restore_key(key), value}
    end
  end

  key_mapping = %{
    # shared attrs
    "fromusername" => "FromUserName",
    "tousername"   => "ToUserName",
    "msgtype"      => "MsgType",
    "createtime"   => "CreateTime",
    "msgid"        => "MsgId",
    # text
    "content"      => "Content",
    "mediaid"      => "MediaId",
    # image
    "picurl"       => "PicUrl",
    # voice
    "format"       => "Format",
    "recognition"  => "Recognition",
    # video & shortvideo
    "thumbmediaid" => "ThumbMediaId",
    # location
    "location_x"   => "Location_X",
    "location_y"   => "Location_Y",
    "scale"        => "Scale",
    "label"        => "Label",
    # link
    "title"        => "Title",
    "description"  => "Description",
    "url"          => "Url",

    # Enctyped message
    "encrypt"      => "Encrypt"
  }
  for {fk, ok} <- key_mapping do
    defp restore_key(unquote(fk)), do: unquote(ok)
  end
  defp restore_key(k) do
    Logger.error("#{k} key canont restored.")
    k
  end
end