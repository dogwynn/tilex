defmodule Tilex.NotImplemented do
  defexception message: "Not currently implemented"
end

defmodule Tilex.LoadError do
  defexception message: "Failed to load file"
end

defmodule Tilex.Element do
  def struct(module, map) when is_map(map) do
    Kernel.struct(module, map)
    # struct = 
    # if Map.hash_key?(struct, :properties) do
    #   properties = struct.properties
    #   |> Enum.map(fn %{ -> 
    #   struct = struct
    #   |> Map.put(:properties, 
  end

  def struct(_module, nil), do: nil
end

defmodule Tilex.Image do
  @moduledoc """
  Tile data 
  """
  defstruct [
    :format,
    :id,
    :source,
    :trans,
    :width,
    :height
  ]

  def from_map(map) do
    Tilex.Element.struct(Tilex.Image, map)
  end
end

defmodule Tilex.Tile do
  @moduledoc """
  Tile data 
  """

  defstruct [
    :id,
    :type,
    :terrain,
    :probability,
    :properties,
    :image,
    :objectgroup,
    :animation
  ]

  def from_map(tile_map) do
    Tilex.Element.struct(Tilex.Tile, tile_map)
  end
end

defmodule Tilex.TileSet do
  @moduledoc """
  TileSet data 
  """

  defstruct [
    :path,
    :firstgid,
    :source,
    :name,
    :tilewidth,
    :tileheight,
    :spacing,
    :margin,
    :tilecount,
    :columns,
    :objectalignment,
    :image,
    :tileoffset,
    :grid,
    :properties,
    :terraintypes,
    :wangsets,
    :tiles
  ]

  def from_map(tileset_map) do
    # IO.inspect(tileset_map)
    Tilex.Element.struct(Tilex.TileSet, tileset_map)
  end
end

defmodule Tilex.Map do
  @moduledoc """
  Map data 
  """

  defstruct [
    :path,
    :version,
    :tiledversion,
    :orientation,
    :renderorder,
    :compressionlevel,
    :width,
    :height,
    :tilewidth,
    :tileheight,
    :hexsidelength,
    :staggeraxis,
    :staggerindex,
    :backgroundcolor,
    :nextlayerid,
    :nextobjectid,
    :infinite,
    :properties,
    :tilesets,
    :layers,
    :editorsettings,
    :objectgroups,
    :groups,
    :imagelayers
  ]

  def from_map(map) do
    Tilex.Element.struct(Tilex.Map, map)
    |> Tilex.Color.convert_colors([:backgroundcolor])
  end

  def load_tileset(%Tilex.Map{tilesets: tilesets, path: path}, tile_index) do
    case tilesets |> Enum.at(tile_index) do
      nil ->
        {:error, {:bad_index, "No tile at index #{tile_index}"}}

      %Tilex.TileSet{source: ts_path} ->
        Tilex.parse_tsx(Path.join(Path.dirname(path), ts_path))
    end
  end

  def load_tileset!(map, tile_index) do
    case load_tileset(map, tile_index) do
      {:ok, tileset} -> tileset
      {:error, error} -> raise Tilex.LoadError, message: inspect(error)
    end
  end
end

defmodule Tilex.EditorSettings do
  defstruct [
    :chunksize,
    :export
  ]

  def from_map(map) do
    Tilex.Element.struct(Tilex.EditorSettings, map)
  end
end

defmodule Tilex.Color do
  @color_re [
    ~r/^#?(?<r>[\da-f][\da-f])(?<g>[\da-f][\da-f])(?<b>[\da-f][\da-f])$/i,
    ~r/^#?(?<a>[\da-f][\da-f])(?<r>[\da-f][\da-f])(?<g>[\da-f][\da-f])(?<b>[\da-f][\da-f])$/i,
    ~r/^#?(?<a>[\da-f])(?<r>[\da-f])(?<g>[\da-f])(?<b>[\da-f])$/i,
    ~r/^#?(?<r>[\da-f])(?<g>[\da-f])(?<b>[\da-f])$/i
  ]
  def regexes, do: @color_re

  def parse(color) do
    case color do
      {r, g, b} when is_integer(r) and is_integer(g) and is_integer(b) ->
        {:ok, {255, r, g, b}}

      {a, r, g, b}
      when is_integer(a) and is_integer(r) and is_integer(g) and
             is_integer(b) ->
        {:ok, {a, r, g, b}}

      "" ->
        {:ok, nil}

      nil ->
        {:ok, nil}

      string when is_binary(string) ->
        match =
          @color_re
          |> Enum.map(&Regex.named_captures(&1, string))
          |> Enum.filter(& &1)
          |> List.first()

        if match do
          ["a", "r", "g", "b"]
          |> Enum.map(&Map.get(match, &1))
          |> Enum.filter(& &1)
          |> Enum.map(&String.pad_trailing(&1, 2, "0"))
          |> Enum.map(&String.to_integer(&1, 16))
          |> List.to_tuple()
          |> parse
        else
          {:error, {:bad_color_binary, string}}
        end

    end
  end

  def convert_colors(struct, atoms) do
    Map.merge(
      struct,
      atoms
      |> Enum.map(fn atom ->
        case parse(Map.get(struct, atom)) do
          {:ok, color} -> {atom, color}
          _ -> {atom, Map.get(struct, atom)}
        end
      end)
      |> Enum.into(%{})
    )
  end
end

defmodule Tilex.Property do
  require Logger

  defstruct [
    :name,
    :type,
    :value
  ]

  def transform_value(%Tilex.Property{type: type, value: value} = property) do
    value =
      case type do
        "" ->
          value

        "string" ->
          value

        "int" ->
          Integer.parse(value)

        "float" ->
          Float.parse(value)

        "bool" ->
          if value == "true", do: true, else: false

        "color" ->
          case Tilex.Color.parse(value) do
            {:ok, color} ->
              color

            {:error, error} ->
              Logger.error("Error parsing color: #{inspect(error)}")
              value
          end

        "file" ->
          value

        "object" ->
          value

        type ->
          Logger.error("Uncaught type: #{type}")
          value
      end

    Map.put(property, :value, value)
  end

  def from_map(map) do
    Tilex.Element.struct(Tilex.Property, map)
    |> transform_value()
  end
end

defmodule Tilex.ObjectGroup do
  require Logger

  defstruct [
    :id,
    :name,
    :color,
    :x,
    :y,
    :width,
    :height,
    :opacity,
    :visible,
    :tintcolor,
    :offsetx,
    :offsety,
    :draworder,
    :properties,
    :objects,
    :animation
  ]

  def from_map(map) do
    Tilex.Element.struct(Tilex.ObjectGroup, map)
    |> Tilex.Color.convert_colors([:color, :tintcolor])
  end
end

defmodule Tilex.Ellipse do
  defstruct [
    :id,
    :name,
    :type,
    :center,
    :width,
    :height,
    :rotation,
    :visible,
    :template
  ]

  def from_object(%{
        id: id,
        name: name,
        type: type,
        x: x,
        y: y,
        width: width,
        height: height,
        rotation: rotation,
        visible: visible,
        template: template,
        ellipse: %{}
      }) do
    %Tilex.Ellipse{
      id: id,
      name: name,
      type: type,
      center: {x, y},
      width: width,
      height: height,
      rotation: rotation,
      visible: visible,
      template: template
    }
  end
end

defmodule Tilex.Point do
  defstruct [
    :id,
    :name,
    :type,
    :point,
    :visible,
    :template
  ]

  def from_object(%{
        id: id,
        name: name,
        type: type,
        x: x,
        y: y,
        visible: visible,
        template: template,
        point: %{}
      }) do
    %Tilex.Point{
      id: id,
      name: name,
      type: type,
      point: {x, y},
      visible: visible,
      template: template
    }
  end
end

defmodule Tilex.Rectangle do
  defstruct [
    :id,
    :name,
    :type,
    :top_left,
    :center,
    :width,
    :height,
    :rotation,
    :visible,
    :template
  ]

  def from_object(%{
        id: id,
        name: name,
        type: type,
        x: x,
        y: y,
        width: width,
        height: height,
        rotation: rotation,
        visible: visible,
        template: template
      }) do
    %Tilex.Rectangle{
      id: id,
      name: name,
      type: type,
      top_left: {x, y},
      center: {x + width / 2, y + height / 2},
      width: width,
      height: height,
      rotation: rotation,
      visible: visible,
      template: template
    }
  end
end

defmodule Tilex.Polygon do
  defstruct [
    :id,
    :name,
    :type,
    :origin,
    :rotation,
    :visible,
    :template,
    :points,
    :translated_points
  ]

  def from_object(%{
        id: id,
        name: name,
        type: type,
        x: x,
        y: y,
        rotation: rotation,
        visible: visible,
        template: template,
        polygon: %{points: points}
      }) do
    points =
      points
      |> String.split(" ")
      |> Enum.flat_map(&String.split(&1, ","))
      |> Enum.map(&Float.parse/1)
      |> Enum.map(fn {f, _} -> f end)
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    %Tilex.Polygon{
      id: id,
      name: name,
      type: type,
      origin: {x, y},
      rotation: rotation,
      visible: visible,
      template: template,
      points: points,
      translated_points:
        points |> Enum.map(fn {px, py} -> {px + x, py + y} end)
    }
  end
end

defmodule Tilex.Polyline do
  defstruct [
    :id,
    :name,
    :type,
    :origin,
    :rotation,
    :visible,
    :template,
    :points,
    :translated_points
  ]

  def from_object(%{
        id: id,
        name: name,
        type: type,
        x: x,
        y: y,
        rotation: rotation,
        visible: visible,
        template: template,
        polyline: %{points: points}
      }) do
    points =
      points
      |> String.split(" ")
      |> Enum.flat_map(&String.split(&1, ","))
      |> Enum.map(&Float.parse/1)
      |> Enum.map(fn {f, _} -> f end)
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    %Tilex.Polyline{
      id: id,
      name: name,
      type: type,
      origin: {x, y},
      rotation: rotation,
      visible: visible,
      template: template,
      points: points,
      translated_points:
        points |> Enum.map(fn {px, py} -> {px + x, py + y} end)
    }
  end
end

defmodule Tilex.Text do
  defstruct [
    :id,
    :name,
    :type,
    :x,
    :y,
    :width,
    :height,
    :rotation,
    :visible,
    :template,
    :fontfamily,
    :pixelsize,
    :wrap,
    :color,
    :bold,
    :italic,
    :underline,
    :strikeout,
    :kerning,
    :halign,
    :valign,
    :text
  ]

  def from_object(%{
        id: id,
        name: name,
        type: type,
        x: x,
        y: y,
        width: width,
        height: height,
        rotation: rotation,
        visible: visible,
        template: template,
        text: %{
          fontfamily: fontfamily,
          pixelsize: pixelsize,
          wrap: wrap,
          color: color,
          bold: bold,
          italic: italic,
          underline: underline,
          strikeout: strikeout,
          kerning: kerning,
          halign: halign,
          valign: valign,
          text: text
        }
      }) do
    %Tilex.Text{
      id: id,
      name: name,
      type: type,
      x: x,
      y: y,
      width: width,
      height: height,
      rotation: rotation,
      visible: visible,
      template: template,
      fontfamily: fontfamily,
      pixelsize: pixelsize,
      wrap: wrap,
      color: color,
      bold: bold,
      italic: italic,
      underline: underline,
      strikeout: strikeout,
      kerning: kerning,
      halign: halign,
      valign: valign,
      text: List.to_string(text)
    }
    |> Tilex.Color.convert_colors([:color])
    
  end
end

defmodule Tilex.TileObject do
  defstruct [
    :id,
    :name,
    :type,
    :x,
    :y,
    :width,
    :height,
    :rotation,
    :visible,
    :template,
    :gid
  ]

  def from_object(%{
        id: id,
        name: name,
        type: type,
        x: x,
        y: y,
        width: width,
        height: height,
        rotation: rotation,
        visible: visible,
        template: template,
        gid: gid
      })
      when is_integer(gid) do
    %Tilex.TileObject{
      id: id,
      name: name,
      type: type,
      x: x,
      y: y,
      width: width,
      height: height,
      rotation: rotation,
      visible: visible,
      template: template,
      gid: Tilex.Gid.from_int(gid)
    }
  end
end

defmodule Tilex.Object do
  defstruct [
    :id,
    :name,
    :type,
    :x,
    :y,
    :width,
    :height,
    :rotation,
    :gid,
    :visible,
    :template,
    :ellipse,
    :point,
    :polygon,
    :polyline,
    :text
  ]

  def transform_object(object) do
    case object do
      %{ellipse: %{}} = map ->
        Tilex.Ellipse.from_object(map)

      %{point: %{}} = map ->
        Tilex.Point.from_object(map)

      %{polygon: %{points: _points}} = map ->
        Tilex.Polygon.from_object(map)

      %{polyline: %{points: _points}} = map ->
        Tilex.Polyline.from_object(map)

      %{text: %{}} = map ->
        Tilex.Text.from_object(map)

      %{gid: gid} = map when is_integer(gid) ->
        Tilex.TileObject.from_object(map)

      %{x: x, y: y, width: width, height: height, point: nil} = map
      when is_float(x) and is_float(y) and is_float(width) and
             is_float(height) ->
        Tilex.Rectangle.from_object(map)

      object ->
        object
    end
  end

  def from_map(map) do
    Tilex.Element.struct(Tilex.Object, map)
    |> transform_object()
  end
end

defmodule Tilex.Data do
  defstruct [
    :encoding,
    :compression,
    :raw,
    :tiles,
    :chunks
  ]

  def from_map(map) do
    Tilex.Element.struct(Tilex.Data, map)
  end
end

defmodule Tilex.Layer do
  require Logger

  defstruct [
    :id,
    :name,
    :x,
    :y,
    :width,
    :height,
    :opacity,
    :visible,
    :tintcolor,
    :offsetx,
    :offsety,
    :properties,
    :data
  ]

  def chunks(%Tilex.Layer{data: %Tilex.Data{chunks: chunks}}) do
    chunks
  end

  def from_map(layer_map) do
    Tilex.Element.struct(Tilex.Layer, layer_map)
    |> Tilex.Color.convert_colors([:tintcolor])
  end

  def gids(%Tilex.Layer{
        width: width,
        data: %Tilex.Data{
          encoding: nil,
          compression: nil,
          chunks: [],
          tiles: tiles
        }
      }) do
    %{
      width: width,
      gids:
        tiles
        |> Enum.map(&(Map.get(&1, :gid) / 2))
        |> Enum.map(&Tilex.Gid.from_int/1)
    }
    |> Tilex.Gid.gid_map()
  end

  def gids(%Tilex.Layer{
        width: width,
        data: %Tilex.Data{chunks: []} = data
      }) do
    with {:ok, gids} <- Tilex.Gid.parse_gids(data) do
      %{width: width, gids: gids}
      |> Tilex.Gid.gid_map()
    end
  end

  def gids(%Tilex.Layer{data: %Tilex.Data{chunks: _chunks}}), do: []
end

defmodule Tilex.Chunk do
  defstruct [
    :x,
    :y,
    :width,
    :height,
    :raw,
    :tiles
  ]

  def from_map(map) do
    Tilex.Element.struct(Tilex.Chunk, map)
  end

  def gids(%Tilex.Chunk{width: width, raw: raw}, %Tilex.Layer{
        data: %Tilex.Data{
          encoding: encoding,
          compression: compression
        }
      }) do
    with {:ok, gids} <-
           Tilex.Gid.parse_gids(%{
             raw: raw,
             encoding: encoding,
             compression: compression
           }) do
      %{width: width, gids: gids}
      |> Tilex.Gid.gid_map()
    end
  end
end

defmodule Tilex.Group do
  defstruct [
    :id,
    :name,
    :offsetx,
    :offsety,
    :opacity,
    :visible,
    :tintcolor,
    :properties,
    :layers,
    :objectgroups,
    :imagelayers,
    :groups
  ]

  def from_map(map) do
    Tilex.Element.struct(Tilex.Group, map)
    |> Tilex.Color.convert_colors([:tintcolor])
  end
end

defmodule Tilex.Gid do
  require Logger

  defstruct [
    :h_flip,
    :v_flip,
    :d_flip,
    :gid
  ]

  def bit(v), do: if(v == 1, do: true, else: false)

  def from_int(nil), do: nil

  def from_int(gid_u32) do
    <<h_flip::1, v_flip::1, d_flip::1, gid::29>> = <<gid_u32::unsigned-32>>

    %Tilex.Gid{
      h_flip: bit(h_flip),
      v_flip: bit(v_flip),
      d_flip: bit(d_flip),
      gid: gid
    }
  end

  def from_bitstring(data, gids \\ [])

  def from_bitstring(<<>>, gids) do
    gids |> Enum.reverse()
  end

  def from_bitstring(<<gid_int::little-unsigned-32, rest::binary>>, gids) do
    from_bitstring(rest, [from_int(gid_int) | gids])
  end

  def parse_gids(%{compression: "gzip", raw: raw, encoding: "base64"}) do
    {:ok,
     raw
     |> :base64.decode()
     |> :zlib.gunzip()
     |> from_bitstring()}
  end

  def parse_gids(%{compression: "zstd", raw: raw, encoding: "base64"}) do
    {:ok,
     raw
     |> :base64.decode()
     |> :zstd.decompress()
     |> from_bitstring()}
  end

  def parse_gids(%{raw: raw, encoding: "csv"}) do
    {:ok,
     raw
     |> List.to_string()
     |> String.trim()
     |> String.split("\n")
     |> Enum.map(&String.trim/1)
     |> Enum.join("")
     |> String.split(",")
     |> Enum.map(&String.to_integer/1)
     |> Enum.map(fn i -> <<i::little-unsigned-32>> end)
     |> Enum.reduce(<<>>, fn l, acc -> acc <> l end)
     |> from_bitstring()}
  end

  def parse_gids(%{encoding: enc}) do
    {:error, {:not_implemented, :encoding, enc}}
    # raise Tilex.NotImplemented, message: "Encoding #{enc} not supported"
  end

  def parse_gids(%{compression: comp}) do
    {:error, {:not_implemented, :compression, comp}}

    # raise Tilex.NotImplemented, message: "Compression #{comp} not supported"
  end

  def parse_gids(layer) do
    Logger.info(inspect(layer))
    {:error, {:no_data}}
  end

  def gid_map(%{width: width, gids: gids}) do
    width = floor(width)

    Enum.zip(0..(Enum.count(gids) - 1), gids)
    |> Enum.map(fn {index, gid} ->
      case gid do
        %{gid: 0} -> nil
        %{gid: nil} -> nil
        gid -> {{div(index, width), rem(index, width)}, gid}
      end
    end)
    |> Enum.filter(& &1)
    # |> Enum.sort_by(fn {{i, j}, v} -> {i, j} end)
    |> Enum.into(%{})
  end
end
