defmodule Identicon do
  @moduledoc """
  Useful functions for creating an identicon based on a string
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
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

  def mirror_row([a,b,c]) do
    [a, b, c, b, a]
  end


  @doc """
  Build a flat grid based on an image generated with hash_input

  ## Examples
      iex> image = Identicon.hash_input("banana")
      iex> Identicon.build_grid(image)
      %Identicon.Image{color: nil,
        grid: [{114, 0}, {179, 1}, {2, 2}, {179, 3}, {114, 4}, {191, 5}, {41, 6},
        {122, 7}, {41, 8}, {191, 9}, {34, 10}, {138, 11}, {117, 12}, {138, 13},
        {34, 14}, {115, 15}, {1, 16}, {35, 17}, {1, 18}, {115, 19}, {239, 20},
        {239, 21}, {124, 22}, {239, 23}, {239, 24}],
        hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]}

  """
  def build_grid(%Identicon.Image{hex: number_list} = image) do
    grid =
      number_list
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image| grid: grid}
  end

  @doc """
  Filters the odd quares out of the image

  ## Examples
      iex> image = Identicon.hash_input("banana") |> Identicon.build_grid
      iex> Identicon.filter_odd_squares(image)
      %Identicon.Image{color: nil,
        grid: [{114, 0}, {2, 2}, {114, 4}, {122, 7}, {34, 10}, {138, 11}, {138, 13},
        {34, 14}, {124, 22}],
        hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]}

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end
    %Identicon.Image{image| grid: grid}
  end


  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      x = rem(index, 5) * 50
      y = div(index, 5) * 50

      top_left = {x,  y}
      bottom_right = {x + 50, y + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image| pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
