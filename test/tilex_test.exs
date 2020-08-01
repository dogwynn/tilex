defmodule TilexTest do
  use ExUnit.Case
  doctest Tilex

  setup_all do
    {:ok,
     test_map_image_tile_set: "test/test_data/test_map_image_tile_set.tmx",
     test_map_infinite: "test/test_data/test_map_infinite.tmx",
     test_map_simple: "test/test_data/test_map_simple.tmx",
     test_map_simple_meme: "test/test_data/test_map_simple_meme.tmx",
     test_map_simple_objects: "test/test_data/test_map_simple_objects.tmx",
     test_map_simple_offset: "test/test_data/test_map_simple_offset.tmx",
     tile_set_image: "test/test_data/tile_set_image.tsx",
     tile_set_image_objects: "test/test_data/tile_set_image_objects.tsx"}
  end

  test "loads test_map_image_tile_set.tmx", state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)
    assert tmx
  end

  test "test_map_image_tile_set.tmx map properties are correct", state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)

    assert tmx.version == "1.2"
    assert tmx.tiledversion == "1.2.3"
    assert tmx.orientation == "orthogonal"
    assert tmx.renderorder == "right-down"
    assert tmx.width == 10
    assert tmx.height == 10
    assert tmx.tilewidth == 32
    assert tmx.tileheight == 32
    assert tmx.infinite == 0
    assert tmx.nextlayerid == 16
    assert tmx.nextobjectid == 10
  end

  test "test_map_image_tile_set.tmx tileset properties are correct",
       state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)

    assert Enum.count(tmx.tilesets) == 1

    ts = tmx.tilesets |> Enum.at(0)

    assert ts.firstgid == 1
    assert ts.source == "tile_set_image.tsx"
  end

  test "test_map_image_tile_set.tmx tileset source can be loaded", state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)

    tsx = Tilex.Map.load_tileset(tmx, 0)
    assert tsx
  end

  test "test_map_image_tile_set.tmx layer data properties are correct",
       state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)

    assert Enum.count(tmx.layers) == 2

    l = tmx.layers |> Enum.at(0)
    assert l.id == 1
    assert l.name == "Tile Layer 1"
    assert l.width == 10
    assert l.height == 10

    l = tmx.layers |> Enum.at(1)
    assert l.id == 2
    assert l.name == "Tile Layer 2"
    assert l.width == 10
    assert l.height == 10
    assert l.opacity == 0.5
  end

  test "test_map_image_tile_set.tmx layer data gids are correct", state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)

    l = tmx.layers |> Enum.at(0)
    gids = l |> Tilex.Layer.gids()

    Enum.zip(0..5, 0..7)
    |> Enum.map(fn {i, j} ->
      assert gids[{i, j}].gid == j + 1 + i * 8
    end)

    l = tmx.layers |> Enum.at(1)
    gids = l |> Tilex.Layer.gids()
    assert gids[{1, 6}].gid == 46
  end

  test "test_map_image_tile_set.tmx group properties are correct", state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)

    g = tmx.groups |> Enum.at(0)
    assert g.properties["bool property"]

    l = g.layers |> Enum.at(0)
    assert l.id == 5
    assert l.name == "Tile Layer 4"
    assert l.width == 10
    assert l.height == 10
    assert l.offsetx == 49
    assert l.offsety == -50

    gid = l |> Tilex.Layer.gids() |> Map.get({8, 1})
    assert gid.gid == 31
    refute gid.h_flip
    refute gid.v_flip
    refute gid.d_flip
    # Missing gid
    refute l |> Tilex.Layer.gids() |> Map.get({1, 1})

    l = g.layers |> Enum.at(1)
    assert l.id == 4
    assert l.name == "Tile Layer 3"
    assert l.width == 10
    assert l.height == 10

    gids = l |> Tilex.Layer.gids()
    gid = gids[{8, 1}]
    assert gid.gid == 10
    refute gid.h_flip
    refute gid.v_flip
    refute gid.d_flip
    assert gids[{8, 2}].gid == 11
  end

  test "test_map_image_tile_set.tmx objectgroup properties are correct",
       state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)

    assert tmx.objectgroups |> Enum.count() == 1

    g = tmx.objectgroups |> Enum.at(0)
    assert g.properties == %{}

    assert g.color == {255, 0, 0, 0}
    assert g.draworder == "index"
    assert g.id == 6
    assert g.name == "Object Layer 1"
    assert g.opacity == 0.9
    assert g.offsetx == 4.66667
    assert g.offsety == -4.33333
  end

  test "test_map_image_tile_set.tmx objectgroup group count correct",
       state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)

    g = tmx.objectgroups |> Enum.at(0)

    objects = g.objects

    assert Enum.count(objects) == 8
  end

  test "test_map_image_tile_set.tmx objectgroup groups are correct",
       state do
    path = state[:test_map_image_tile_set]
    tmx = Tilex.parse_tmx!(path)

    g = tmx.objectgroups |> Enum.at(0)

    objects = g.objects

    assert Enum.count(objects) == 8

    attributes = [
      %{
        id: 1,
        name: "rectangle 1",
        type: "rectangle type",
        top_left: {200.25, 210.75},
        width: 47.25,
        height: 25,
        rotation: 15
      },
      %{
        id: 2,
        name: "polygon 1",
        type: "polygon type",
        origin: {252.5, 87.75},
        rotation: -21,
        points: [
          {0, 0},
          {-41.25, 24.25},
          {-11, 67.25},
          {25.75, 39.75},
          {-9, 37.75}
        ]
      }
    ]

    Enum.zip(Enum.take(objects, Enum.count(attributes)), attributes)
    |> Enum.map(fn o, a ->
      a
      |> Enum.map(fn {k, v} ->
        Logger.error(inspect(o))
        assert Map.get(o, k) == v
      end)
    end)
  end

  test "loads map infinite", state do
    path = state[:test_map_infinite]
    tmx = Tilex.parse_tmx!(path)
    assert tmx
  end

  test "loads map simple", state do
    path = state[:test_map_simple]
    tmx = Tilex.parse_tmx!(path)
    assert tmx
  end

  test "loads map simple meme", state do
    path = state[:test_map_simple_meme]
    tmx = Tilex.parse_tmx!(path)
    assert tmx
  end

  test "loads map simple objects", state do
    path = state[:test_map_simple_objects]
    tmx = Tilex.parse_tmx!(path)
    assert tmx
  end

  test "loads map simple offset", state do
    path = state[:test_map_simple_offset]
    tmx = Tilex.parse_tmx!(path)
    assert tmx
  end

  test "loads tileset image", state do
    path = state[:tile_set_image]
    tsx = Tilex.parse_tsx!(path)
    assert tsx
  end

  test "loads tileset image_objects", state do
    path = state[:tile_set_image_objects]
    tsx = Tilex.parse_tsx!(path)
    assert tsx
  end
end
