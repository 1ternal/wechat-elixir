defmodule Wechat.Message do
  defmodule Incoming do
    def types, do: [
      #normal message
      :image,
      :link,
      :location,
      :shortvideo,
      :text,
      :video,
      :voice,
      # events
      :event_subscribe,
      :event_unsubscribe,
      :event_scan,
      :event_location,
      :event_click,
      :event_view,
      # todo not impl
      :batch_job,
    ]
    @moduledoc """

    received message
    ref: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140453

    shared
    <xml>
      <ToUserName><![CDATA[toUser]]></ToUserName>
      <FromUserName><![CDATA[fromUser]]></FromUserName>
      <CreateTime>1348831860</CreateTime>
      <MsgType><![CDATA[text]]></MsgType>
      <MsgId>1234567890123456</MsgId>
    </xml>

    text
    <xml>
      <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[this is a test]]></Content>
    </xml>

    image
    <xml>
      <MsgType><![CDATA[image]]></MsgType>
      <PicUrl><![CDATA[this is a url]]></PicUrl>
      <MediaId><![CDATA[media_id]]></MediaId>
    </xml>

    voice
    <xml>
      <MsgType><![CDATA[voice]]></MsgType>
      <MediaId><![CDATA[media_id]]></MediaId>
      <Format><![CDATA[Format]]></Format>
      <Recognition><![CDATA[腾讯微信团队]]></Recognition> ## Optional
    </xml>

    video
    <xml>
      <MsgType><![CDATA[video]]></MsgType>
      <MediaId><![CDATA[media_id]]></MediaId>
      <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
    </xml>

    shortvideo
    <xml>
      <MsgType><![CDATA[shortvideo]]></MsgType>
      <MediaId><![CDATA[media_id]]></MediaId>
      <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
    </xml>

    location
    <xml>
      <MsgType><![CDATA[location]]></MsgType>
      <Location_X>23.134521</Location_X>
      <Location_Y>113.358803</Location_Y>
      <Scale>20</Scale>
      <Label><![CDATA[位置信息]]></Label>
    </xml>

    link
    <xml>
      <MsgType><![CDATA[link]]></MsgType>
      <Title><![CDATA[公众平台官网链接]]></Title>
      <Description><![CDATA[公众平台官网链接]]></Description>
      <Url><![CDATA[url]]></Url>
    </xml>

    events
    ref: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140454

    subsribe/unsubsribe
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[subscribe]]></Event>
    </xml>

    subscribe with scene
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[subscribe]]></Event>
      <EventKey><![CDATA[qrscene_123123]]></EventKey>
      <Ticket><![CDATA[TICKET]]></Ticket>
    </xml>

    scan event
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[SCAN]]></Event>
      <EventKey><![CDATA[SCENE_VALUE]]></EventKey>
      <Ticket><![CDATA[TICKET]]></Ticket>
    </xml>

    location event
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[LOCATION]]></Event>
      <Latitude>23.137466</Latitude>
      <Longitude>113.352425</Longitude>
      <Precision>119.385040</Precision>
    </xml>

    custom menu click event
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[CLICK]]></Event>
      <EventKey><![CDATA[EVENTKEY]]></EventKey>
    </xml>

    custom menu link event
    <xml>
      <MsgType><![CDATA[event]]></MsgType>
      <Event><![CDATA[VIEW]]></Event>
      <EventKey><![CDATA[www.qq.com]]></EventKey>
    </xml>
    """
  end

  defmodule Reply do
    @moduledoc """
    Reply message

    Message Types ref: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140543
    """

    defmodule Text do
      @moduledoc """
      text reply message struct
      """
      @enforce_keys ~W(to_user_name from_user_name create_time msg_type)a ++ ~W(content)a
      defstruct @enforce_keys

      @behaviour Access
      def fetch(term, key),                    do: Map.fetch(term, key)
      def get(term, key, default),             do: Map.get(term, key, default)
      def get_and_update(data, key, function), do: Map.get_and_update(data, key, function)
      def pop(data, key),                      do: Map.pop(data, key)
    end

    defmodule Image do
      @moduledoc """
      image reply message struct
      """
      @enforce_keys ~W(to_user_name from_user_name create_time msg_type)a ++ ~W(media_id)a
      defstruct @enforce_keys
    end

    defmodule Voice do
      @moduledoc """
      voice reply message struct
      """
      @enforce_keys ~W(to_user_name from_user_name create_time msg_type)a ++ ~W(media_id)a
      defstruct @enforce_keys
    end

    defmodule Video do
      @moduledoc """
      video reply message struct
      """
      @enforce_keys ~W(to_user_name from_user_name create_time msg_type)a ++ ~W(media_id)a
      defstruct @enforce_keys ++ ~W(title description)a
    end

    defmodule Music do
      @moduledoc """
      music reply message struct
      """
      @enforce_keys ~W(to_user_name from_user_name create_time msg_type)a ++ ~W(h_q_music_url thumb_media_id)a
      defstruct @enforce_keys ++ ~W(title description)a
    end

    defmodule News do
      @moduledoc """
      news reply message struct
      """
      @enforce_keys ~W(to_user_name from_user_name create_time msg_type)a ++ ~W(article_count articles title description pic_url url)a
      defstruct @enforce_keys
    end

    def types, do: ~W(text image voice video music news)a
  end

  def msg_type(msg, type) do
    Map.put(msg, "MsgType", type)
  end

  attrs_in_root = ~w(to_user_name from_user_name create_time content)a
  for attr <- attrs_in_root do
    msg_attr = attr |> to_string |> Macro.camelize
    def unquote(attr)(msg, content) do
      Map.put(msg, unquote(msg_attr), content)
    end
  end

  sub_attrs = ~w(image voice video music)a
  for attr <- sub_attrs do
    msg_type = Atom.to_string(attr)
    sub_attr = attr |> to_string |> String.capitalize

    def unquote(attr)(msg, detail) when is_list(detail) or is_map(detail) do
      detail =
        for {k, v} <- detail, into: %{} do
          {to_msg_attr(k), v}
        end

      msg
      |> Map.put("MsgType", unquote(msg_type))
      |> Map.put(unquote(sub_attr), detail)
    end

    def media_id(%{"MsgType" => unquote(msg_type)} = msg, id) do
      put_in_sub(msg, unquote(msg_type), "MediaId", id)
    end

    def title(%{"MsgType" => unquote(msg_type)} = msg, content) do
      put_in_sub(msg, unquote(msg_type), "Title", content)
    end

    def description(%{"MsgType" => unquote(msg_type)} = msg, content) do
      put_in_sub(msg, unquote(msg_type), "Description", content)
    end
  end

  def media_id(_, _), do: raise "media id cannot be set, due to the type of message are unknown"
  def title(_, _),    do: raise "title cannot be set, due to the type of message are unknown"
  def description(_, _),    do: raise "title cannot be set, due to the type of message are unknown"

  def music_url(msg, content),      do: Map.update(msg, "Music", %{}, & Map.put(&1, "MusicUrl", content))
  def hq_music_url(msg, content),   do: Map.update(msg, "Music", %{}, & Map.put(&1, "HQMusicUrl", content))
  def thumb_media_id(msg, content), do: Map.update(msg, "Music", %{}, & Map.put(&1, "ThumbMediaId", content))

  def article(msg, item) do
    item = for {k, v} <- item, into: %{} do
      {to_msg_attr(k), v}
    end

    msg
    |> Map.update("Articles", [item: item], fn articles ->
      articles ++ [item: item]
    end)
    |> Map.update("ArticleCount", 1, & &1 + 1)
  end

  defp put_in_sub(%{"MsgType" => type} = msg, type, attr, content) do
    Map.update(msg, String.capitalize(type), %{attr => content}, & Map.put(&1, attr, content))
  end

  defp to_msg_attr(:hq_music_url), do: "HQMusicUrl"
  defp to_msg_attr(attr) when is_atom(attr) do
    attr |> to_string |> Macro.camelize
  end
end
