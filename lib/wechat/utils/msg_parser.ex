defmodule Wechat.Utils.MsgParser do
  @moduledoc """
  Parse wechat xml message.
  Generate a map structured message with plain xml.
  """

  @doc ~S"""
  parse the incoming xml message
  atomify and underscore the key

  ## Example
      iex> Wechat.Utils.MsgParser.parse("...")
          %{
            to_user_name:    "...",
            from_user_name:  "...",
            create_time:     "...",
            msg_type:        "...",
            msg_id:          "...",
          }
  """
  def parse(xml) when is_binary(xml) do
    [{"xml", [], attrs}] = Floki.find(xml, "xml")
    for {key, _, [value]} <- attrs, into: %{} do
      {parse_key(key), value}
    end
  end

  @doc """
  restore the reply message
  stringtify and camelize the key
  ## Example
      iex> Wechat.Utils.MsgParser.restore("...")
          %{
            ToUserName:    "...",
            FromUserName:  "...",
            CreateTime:     "...",
            MsgType:        "...",
          }
  """
  def restore(reply) when is_map(reply) do
    for {k, v} <- reply, into: %{} do
      {restore_key(k), restore(v)}
    end
  end
  def restore(reply) when is_list(reply) do
    for {k, v} <- reply do
      {restore_key(k), restore(v)}
    end
  end
  def restore(v), do: v

  key_mapping = %{
    from_user_name:  "FromUserName",
    to_user_name:    "ToUserName",
    msg_type:        "MsgType",
    create_time:     "CreateTime",
    msg_id:          "MsgId",
    # incoming
    content:         "Content",
    media_id:        "MediaId",
    pic_url:         "PicUrl",
    format:          "Format",
    recognition:     "Recognition",
    thumb_media_id:  "ThumbMediaId",
    location_x:      "Location_X",
    location_y:      "Location_Y",
    scale:           "Scale",
    label:           "Label",
    title:           "Title",
    description:     "Description",
    url:             "Url",
    encrypt:         "Encrypt",
    # event
    event:          "Event",
    event_key:      "EventKey",
    ticket:         "Ticket",
    latitude:       "Latitude",
    longitude:      "Longitude",
    precision:      "Precision",

    # reply
    image:           "Image",
    voice:           "Voice",
    video:           "Video",
    music:           "Music",
    hq_music_url:    "HQMusicUrl",
    music_url:       "MusicUrl",
    article_count:   "ArticleCount",
    articles:        "Articles",
    item:            "item",
  }
  for {atom_key, origin_key} <- key_mapping do
    floki_key = String.downcase(origin_key)
    defp parse_key(unquote(floki_key)), do: unquote(atom_key)

    defp restore_key(unquote(atom_key)), do: unquote(origin_key)
  end
end
