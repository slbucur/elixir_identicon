defmodule Identicon do
  @moduledoc """
  Useful functions for creating an identicon based on a string
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
  end

  @doc """
  Returns an Images with a list of numbers based on the MD5 of a stric

  ## Examples

      iex> Identicon.hash_input("banana")
      %Identicon.Image{hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]}
  """
  def hash_input(input) do
    hex_image = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    %Identicon.Image{hex: hex_image}
  end


  @doc """
  Picks the color based on an image generated through `hash_input`

  ## Examples
      iex> image = Identicon.hash_input("banana")
      iex> Identicon.pick_color(image)
      %Identicon.Image{
        color: {114, 179, 2},
        hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]}
  """
  def pick_color(image) do
    %Identicon.Image{hex: [r, g, b | _remaining ]} = image
    %Identicon.Image{image | color: {r, g, b}}
  end


end
