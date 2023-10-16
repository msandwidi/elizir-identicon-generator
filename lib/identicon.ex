defmodule Identicon do
  require Integer

  @moduledoc """
    Module for generating identicons
  """

  @doc """
    Generates the identicon based on a string input

  ## Examples

      iex> Identicon.generate("banana")
      iex> :ok

  """
  def generate(input) do
    input
      |> hash_input
      |> pick_color
      |> build_grid
      |> filter_odd_squares
      |> build_pixel_map
      |> draw_image
      |> save_image input
  end

  defp save_image(image, input) do
    File.write("#{input}.png", image)
  end

  defp draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} -> 
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = img) do
    pixel_map = Enum.map grid, fn {_, i} -> 

      horizontal = rem(i, 5) * 50
      vertical = div(i, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{img | pixel_map: pixel_map}
  end

  defp hash_input(input) do
    hex = :crypto.hash(:md5, input)
      |> :binary.bin_to_list

      %Identicon.Image{hex: hex}
  end

  defp pick_color(%Identicon.Image{hex: [r, g, b | _]} = img) do
    %Identicon.Image{img | color: {r, g, b}}
  end

  defp build_grid(%Identicon.Image{hex: hex} = img) do
    grid = 
      hex
      |> Enum.chunk(3)
      #|> Enum.map(fn x -> mirror_row(x) end)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{img | grid: grid}
  end

  defp filter_odd_squares(%Identicon.Image{grid: grid} = img) do
    grid = 
      Enum.filter(grid, fn {x, _} -> Integer.is_even(x) end)

      %Identicon.Image{img | grid: grid} 
  end

  defp mirror_row([a, b, c]) do
    [a, b, c, b, a]
  end
end
