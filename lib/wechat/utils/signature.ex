defmodule Wechat.Utils.Signature do
  @moduledoc """
  Check and Generate signature.
  """

  def valid?(signature, args) when is_binary(signature) and is_list(args) do
    signature == sign(args)
  end

  def sign(args) do
    args
    |> Enum.sort
    |> Enum.join
    |> sha1
  end

  defp sha1(str) do
    digest = :crypto.hash(:sha, str)
    Base.encode16(digest, case: :lower)
  end
end
