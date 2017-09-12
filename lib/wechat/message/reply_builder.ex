defmodule Wechat.Message.ReplyBuilder do

  def msg_type(msg, type) do
    Map.put(msg, :msg_type, type)
  end

  attrs_in_root = ~w(to_user_name from_user_name create_time content)a
  for attr <- attrs_in_root do
    def unquote(attr)(msg, content) do
      Map.put(msg, unquote(attr), content)
    end
  end

  sub_attrs = ~w(image voice video music)a
  for attr <- sub_attrs do
    type_str = Atom.to_string(attr)

    def unquote(attr)(msg, detail) when is_list(detail) or is_map(detail) do
      msg
      |> Map.put(:msg_type, unquote(type_str))
      |> Map.put(unquote(attr), Enum.into(detail, %{}))
    end

    def media_id(%{msg_type: unquote(type_str)} = msg, id) do
      put_in_sub(msg, unquote(type_str), :media_id, id)
    end

    def title(%{msg_type: unquote(type_str)} = msg, content) do
      put_in_sub(msg, unquote(type_str), :title, content)
    end

    def description(%{msg_type: unquote(type_str)} = msg, content) do
      put_in_sub(msg, unquote(type_str), :description, content)
    end
  end

  def media_id(_, _), do: raise "media id cannot be set, due to the type of message are unknown"
  def title(_, _),    do: raise "title cannot be set, due to the type of message are unknown"
  def description(_, _),    do: raise "title cannot be set, due to the type of message are unknown"

  def music_url(msg, content),      do: Map.update(msg, :music, %{}, & Map.put(&1, :music_url, content))
  def hq_music_url(msg, content),   do: Map.update(msg, :music, %{}, & Map.put(&1, :hq_music_url, content))
  def thumb_media_id(msg, content), do: Map.update(msg, :music, %{}, & Map.put(&1, :thumb_media_id, content))


  def article(msg, item) when is_list(item) do
    article(msg, Enum.into(item, %{}))
  end
  def article(msg, item) when is_map(item) do
    msg
    |> Map.update(:articles, [item: item], fn articles ->
      articles ++ [item: item]
    end)
    |> Map.update(:article_count, 1, & &1 + 1)
  end

  defp put_in_sub(%{msg_type: type} = msg, type, attr, content) when is_binary(type) do
    sub_attr = String.to_atom(type)
    Map.update(msg, sub_attr, %{attr => content}, & Map.put(&1, attr, content))
  end
end
