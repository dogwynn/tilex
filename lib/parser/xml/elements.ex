defmodule Tilex.Map.Xml do
  require Logger
  import SweetXml

  def parse!(nil), do: nil

  def parse!(doc_elem) do
    doc_elem
    |> xpath(
      ~x"/map",
      version: ~x"@version"s,
      tiledversion: ~x"@tiledversion"s,
      orientation: ~x"@orientation"s,
      renderorder: ~x"@renderorder"s,
      compressionlevel: ~x"@compressionlevel"io,
      width: ~x"@width"i,
      height: ~x"@height"i,
      tilewidth: ~x"@tilewidth"i,
      tileheight: ~x"@tileheight"i,
      hexsidelength: ~x"@hexsidelength"fo,
      staggeraxis: ~x"@staggeraxis"so,
      staggerindex: ~x"@staggerindex"so,
      backgroundcolor: ~x"@backgroundcolor"so,
      nextlayerid: ~x"@nextlayerid"i,
      nextobjectid: ~x"@nextobjectid"i,
      infinite: ~x"@infinite"io,

      properties: ~x"." |> transform_by(&Tilex.Property.Xml.parse_many!/1),
      tilesets: ~x"." |> transform_by(&Tilex.TileSet.Xml.parse_many!/1),
      layers: ~x"." |> transform_by(&Tilex.Layer.Xml.parse_many!/1),
      editorsettings:
        ~x"." |> transform_by(&Tilex.EditorSettings.Xml.parse_many!/1),
      objectgroups:
        ~x"." |> transform_by(&Tilex.ObjectGroup.Xml.parse_many!/1),
      groups: ~x"." |> transform_by(&Tilex.Group.Xml.parse_many!/1),
      imagelayers:
        ~x"." |> transform_by(&Tilex.ImageLayer.Xml.parse_many!/1)
    )
    |> Tilex.Map.from_map()
  end
end

defmodule Tilex.EditorSettings.Xml do
  require Logger
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./editorsettings"lo)
    |> Enum.map(&parse!/1)
  end

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/editorsettings"o,
      chunksize: [
        ~x"./chunksize"o,
        width: ~x"@width"fo,
        height: ~x"@height"fo
      ],
      export: [
        ~x"./export"o,
        target: ~x"@target"s,
        format: ~x"@format"s
      ]
    )
    |> Tilex.EditorSettings.from_map()
  end
end

defmodule Tilex.TileSet.Xml do
  require Logger
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./tileset"lo)
    |> Enum.map(&parse!/1)
  end

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/tileset"o,
      firstgid: ~x"@firstgid"io,
      source: ~x"@source"so,
      name: ~x"@name"so,
      tilewidth: ~x"@tilewidth"fo,
      tileheight: ~x"@tileheight"fo,
      spacing: ~x"@spacing"fo,
      margin: ~x"@margin"fo,
      tilecount: ~x"@tilecount"io,
      columns: ~x"@columns"io,
      image: ~x"./image" |> transform_by(&Tilex.Image.Xml.parse!/1),
      objectalignment: ~x"@objectalignment"so,

      tileoffset: [
        ~x"./tileoffset"o,
        x: ~x"@x"fo,
        y: ~x"@y"fo
      ],

      grid: [
        ~x"./grid"o,
        orientation: ~x"@orientation"so,
        width: ~x"@width"i,
        height: ~x"@height"i
      ],

      properties: ~x"." |> transform_by(&Tilex.Property.Xml.parse_many!/1),

      terraintypes: [
        ~x"./terraintypes/terrain"lo,
        name: ~x"@name"s,
        tile: ~x"@tile"i
      ],

      wangsets: [
        ~x"./wangsets/wangset"lo,
        name: ~x"@name"s,
        tile: ~x"@tile"i,
        properties: ~x"." |> transform_by(&Tilex.Property.Xml.parse_many!/1),
        wangcornercolor: [
          ~x"./wangcornercolor"lo,
          name: ~x"@name"s,
          color: ~x"@color"s,
          tile: ~x"@tile"i,
          probability: ~x"@probability"fo
        ],
        wangedgecolor: [
          ~x"./wangedgecolor"lo,
          name: ~x"@name"s,
          color: ~x"@color"s,
          tile: ~x"@tile"i,
          probability: ~x"@probability"fo
        ],
        wangtile: [
          ~x"./wangtile"lo,
          tileid: ~x"@tileid"i,
          wangid: ~x"@wangid"i,
          hflip: ~x"@hflip"o,
          vflip: ~x"@vflip"o,
          dflip: ~x"@dflip"o
        ]
      ],

      tiles: ~x"." |> transform_by(&Tilex.Tile.Xml.parse_many!/1)
    )
    |> Tilex.TileSet.from_map()
  end
end

defmodule Tilex.Tile.Xml do
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./tile"lo)
    |> Enum.map(&parse!/1)
  end

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/tile"o,
      id: ~x"@id"i,
      type: ~x"@type"so,
      terrain: ~x"@terrain"o,
      probability: ~x"@probability"fo,
      properties: ~x"." |> transform_by(&Tilex.Property.Xml.parse_many!/1),
      image: ~x"./image" |> transform_by(&Tilex.Image.Xml.parse!/1),
      objectgroup:
        ~x"./objectgroup" |> transform_by(&Tilex.ObjectGroup.Xml.parse!/1),
      animation: [
        ~x"./animation/frame"lo,
        tileid: ~x"@tileid"io,
        duration: ~x"@duration"fo
      ]
    )
    |> Tilex.Tile.from_map()
  end
end

defmodule Tilex.Image.Xml do
  require Logger
  import SweetXml

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/image"o,
      format: ~x"@format"s,
      id: ~x"@id"io,
      source: ~x"@source"s,
      trans: ~x"@trans"so,
      width: ~x"@width"fo,
      height: ~x"@height"fo
    )
    |> Tilex.Image.from_map()
  end
end

defmodule Tilex.Property.Xml do
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./properties/property"lo)
    |> Enum.map(&parse!/1)
    |> Enum.map(fn %{name: name} = p -> {name, p} end)
    |> Enum.into(%{})
  end

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/property"o,
      name: ~x"@name"so,
      type: ~x"@type"so,
      value: ~x"@value"so
    )
    |> Tilex.Property.from_map()
  end
end

defmodule Tilex.ObjectGroup.Xml do
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./objectgroup"lo)
    |> Enum.map(&parse!/1)
  end

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/objectgroup"o,
      id: ~x"@id"io,
      name: ~x"@name"so,
      color: ~x"@color"so,
      x: ~x"@x"fo,
      y: ~x"@y"fo,
      width: ~x"@width"fo,
      height: ~x"@height"fo,
      opacity: ~x"@opacity"fo,
      visible: ~x"@visible"io,
      tintcolor: ~x"@tintcolor"so,
      offsetx: ~x"@offsetx"fo,
      offsety: ~x"@offsety"fo,
      draworder: ~x"@draworder"so,
      properties: ~x"." |> transform_by(&Tilex.Property.Xml.parse_many!/1),
      objects: ~x"." |> transform_by(&Tilex.Object.Xml.parse_many!/1),
      animation: [
        ~x"./animation/frame"lo,
        tileid: ~x"@tileid"io,
        duration: ~x"@duration"fo
      ]
    )
    |> Tilex.ObjectGroup.from_map()
  end
end

defmodule Tilex.Object.Xml do
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./object"lo)
    |> Enum.map(&parse!/1)
  end

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/object"o,
      id: ~x"@id"i,
      name: ~x"@name"so,
      type: ~x"@type"so,
      x: ~x"@x"fo,
      y: ~x"@y"fo,
      width: ~x"@width"fo,
      height: ~x"@height"fo,
      rotation: ~x"@rotation"fo,
      gid: ~x"@gid"io,
      visible: ~x"@visible"io,
      template: ~x"@template"so,
      ellipse: [~x"./ellipse"o],
      point: [~x"./point"o],
      polygon: [~x"./polygon"o, points: ~x"@points"so],
      polyline: [~x"./polyline"o, points: ~x"@points"so],
      text: [
        ~x"./text"o,
        fontfamily: ~x"@fontfamily"so,
        pixelsize: ~x"@pixelsize"fo,
        wrap: ~x"@wrap"io,
        color: ~x"@color"so,
        bold: ~x"@bold"io,
        italic: ~x"@italic"io,
        underline: ~x"@underline"io,
        strikeout: ~x"@strikeout"io,
        kerning: ~x"@kerning"io,
        halign: ~x"@halign"so,
        valign: ~x"@valign"so,
        text: ~x"text()",
      ]
    )
    |> Tilex.Object.from_map()
  end
end

defmodule Tilex.Layer.Xml do
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./layer"lo)
    |> Enum.map(&parse!/1)
  end

  def parse_options() do
    [
      id: ~x"@id"i,
      name: ~x"@name"so,
      x: ~x"@x"fo,
      y: ~x"@y"fo,
      width: ~x"@width"i,
      height: ~x"@height"i,
      opacity: ~x"@opacity"fo,
      visible: ~x"@visible"io,
      tintcolor: ~x"@tintcolor"so,
      offsetx: ~x"@offsetx"fo,
      offsety: ~x"@offsety"fo,
      properties: ~x"." |> transform_by(&Tilex.Property.Xml.parse_many!/1),
      data: ~x"./data" |> transform_by(&Tilex.Data.Xml.parse!/1),
      image: ~x"./image" |> transform_by(&Tilex.Image.Xml.parse!/1)
    ]
  end

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/layer"o,
      parse_options()
    )
    |> Tilex.Layer.from_map()
  end
end

defmodule Tilex.Data.Xml do
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./data"lo)
    |> Enum.map(&parse!/1)
  end

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/data"o,
      encoding: ~x"@encoding"so,
      compression: ~x"@compression"so,
      tiles: [
        ~x"./tile"lo,
        gid: ~x"@gid"io
      ],
      chunks: ~x"." |> transform_by(&Tilex.Chunk.Xml.parse_many!/1),
      raw: ~x"text()"
    )
    |> Tilex.Data.from_map()
  end
end

defmodule Tilex.Chunk.Xml do
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./chunk"lo)
    |> Enum.map(&parse!/1)
  end

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/chunk"o,
      x: ~x"@x"f,
      y: ~x"@y"f,
      width: ~x"@width"f,
      height: ~x"@height"f,
      tiles: [
        ~x"./tile"lo,
        gid: ~x"@gid"io
      ],
      raw: ~x"text()"
    )
    |> Tilex.Chunk.from_map()
  end
end

defmodule Tilex.ImageLayer.Xml do
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./imagelayer"lo)
    |> Enum.map(&parse!/1)
  end

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/imagelayer"o,
      Tilex.Layer.Xml.parse_options()
    )
    |> Tilex.Layer.from_map()
  end
end

defmodule Tilex.Group.Xml do
  import SweetXml

  def parse_many!(elem) do
    elem
    |> xpath(~x"./group"lo)
    |> Enum.map(&parse!/1)
  end

  def parse!(nil), do: nil

  def parse!(elem) do
    elem
    |> xpath(
      ~x"/group"o,
      id: ~x"@id"i,
      name: ~x"@name"so,
      offsetx: ~x"@offsetx"fo,
      offsety: ~x"@offsety"fo,
      opacity: ~x"@opacity"fo,
      visible: ~x"@visible"io,
      tintcolor: ~x"@tintcolor"so,
      properties: ~x"." |> transform_by(&Tilex.Property.Xml.parse_many!/1),
      layers: ~x"." |> transform_by(&Tilex.Layer.Xml.parse_many!/1),
      objectgroups:
        ~x"." |> transform_by(&Tilex.ObjectGroup.Xml.parse_many!/1),
      imagelayers:
        ~x"." |> transform_by(&Tilex.ImageLayer.Xml.parse_many!/1),
      groups: ~x"." |> transform_by(&Tilex.Group.Xml.parse_many!/1)
    )
    |> Tilex.Group.from_map()
  end
end
