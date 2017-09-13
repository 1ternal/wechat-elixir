defmodule Wechat.Message.ReplyBuilder do
  @moduledoc """
  reply helper func for reply message
  """

  # delegated functions
  def to_user(msg, content), do: to_user_name(msg, content)
  def from_user(msg, content), do: from_user_name(msg, content)

  @doc """
  Transform reply message to specific `type` and populate default attributes
  """
  def type(msg, type) when is_atom(type), do: type(msg, to_string(type))
  def type(msg, type), do: default_reply_with(msg, type)

  defp default_reply_with(%{} = msg, type) when is_binary(type) do
    msg
    |> switch_user
    |> msg_type(type)
    |> create_time(System.system_time(:seconds))
  end

  # batch generate function like ReplyBuilder.to_user_name(msg, who)
  @root_attrs ~w(to_user_name from_user_name create_time msg_type content)a
  for msg_attr <- @root_attrs do
    def unquote(msg_attr)(%{} = msg, content) when is_binary(content) or is_integer(content) do
      Map.put(msg, unquote(msg_attr), content)
    end
  end

  def text(%{} = msg, content) when is_binary(content) do
    msg
    |> type(:text)
    |> content(content)
  end

  def image(%{} = msg, media_id) when is_binary(media_id) do
    msg
    |> type(:image)
    |> media_id(media_id)
  end

  def voice(%{} = msg, media_id) when is_binary(media_id) do
    msg
    |> type(:voice)
    |> media_id(media_id)
  end

  def video(%{} = msg, sub_content) when is_list(sub_content),
    do: video(msg, Enum.into(sub_content, %{}))
  def video(%{} = msg, sub_content) when is_map(sub_content) do
    msg
    |> type(:video)
    |> Map.put(:video, sub_content)
  end

  def music(%{} = msg, sub_content) when is_list(sub_content),
    do: music(msg, Enum.into(sub_content, %{}))
  def music(%{} = msg, sub_content) when is_map(sub_content) do
    msg
    |> type(:music)
    |> Map.put(:music, sub_content)
  end

  def music_url(%{} = msg, content) when is_binary(content),
    do: optimistic_put_in_map(msg, [:music, :music_url], content)

  def hq_music_url(%{} = msg, content) when is_binary(content),
    do: optimistic_put_in_map(msg, [:music, :hq_music_url], content)

  def thumb_media_id(%{} = msg, content) when is_binary(content),
    do: optimistic_put_in_map(msg, [:music, :thumb_media_id], content)

  def article(%{} = msg, sub_content) when is_list(sub_content),
    do: article(msg, Enum.into(sub_content, %{}))

  def article(%{} = msg, sub_content) when is_map(sub_content) do
    msg
    |> Map.update(:articles, [item: sub_content], & &1 ++ [item: sub_content])
    |> Map.update(:article_count, 1, & &1 + 1)
  end

  @sub_attrs ~w(image voice video music)a
  for attr <- @sub_attrs do
    attr_str = Atom.to_string(attr)

    def media_id(%{msg_type: unquote(attr_str)} = msg, content) when is_binary(content),
      do: optimistic_put_in_map(msg, [unquote(attr), :media_id], content)

    def title(%{msg_type: unquote(attr_str)} = msg, content) when is_binary(content),
      do: optimistic_put_in_map(msg, [unquote(attr), :title], content)

    def description(%{msg_type: unquote(attr_str)} = msg, content) when is_binary(content),
      do: optimistic_put_in_map(msg, [unquote(attr), :description], content)
  end

  defp optimistic_put_in_map(%{} = msg, [top_level, next_level], content) do
    Map.update(msg, top_level,  %{next_level => content}, & Map.put(&1, next_level, content))
  end

  def switch_user(%{from_user_name: from, to_user_name: to}) do
    %{from_user_name: to, to_user_name: from}
  end
end
