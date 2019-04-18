require 'chunky_png'

SQRT3 = (3**(1.0/2))
SIZE = 30
HEIGHT = SQRT3/2 * SIZE
SIN60 = SQRT3/2
COS60 = 0.5

Pix = Struct.new(:r, :g, :b)

class V2 < Struct.new(:x, :y)
  def to_s
    "(#{x}, #{y})"
  end

  def add(other)
    V2.new(self.x+other.x, self.y+other.y)
  end

  def round
    V2.new(self.x.round, self.y.round)
  end

  def floor
    V2.new(self.x.floor, self.y.floor)
  end

  def ceil
    V2.new(self.x.ceil, self.y.ceil)
  end
end

def hex()
  result = []

  (SIZE/2..SIZE).each do |row|
    limit = (-SQRT3 * (row - SIZE)).floor
    (-limit..limit).each do |col|
      result << V2.new(col, row)
    end
  end

  (-SIZE/2..SIZE/2).each do |row|
    (-HEIGHT.round..HEIGHT.round).each do |col|
      result << V2.new(col, row)
    end
  end

  (-SIZE..-SIZE/2).each do |row|
    limit = (SQRT3 * (row + SIZE)).floor
    (-limit..limit).each do |col|
      result << V2.new(col, row)
    end
  end

  result
end

def hex_f()
  result = []
  m = 2
  step1 = V2.new(SQRT3/2/m, -0.5/m)
  step2 = V2.new(SQRT3/2/m, 0.5/m)

  start = V2.new(-HEIGHT, SIZE/2.0)
  (m*SIZE+1).times do |j|
    p = start
    (2*m*SIZE+1-j).times do |i|
      result << p
      p = p.add(step1)
    end
    start = start.add(step2)
  end

  step2 = V2.new(0, 1.0/m)
  start = V2.new(-HEIGHT, -SIZE/2.0)
  (m*SIZE).times do |j|
    p = start
    (m*SIZE+1+j).times do |i|
      result << p
      p = p.add(step1)
    end
    start = start.add(step2)
  end

  result
end

HEX = hex()

def shift(point, vec)
  V2.new(point.x+vec.x, point.y+vec.y)
end

def shift_all(points, vec)
  points.map { |p| shift(p, vec) }
end

def round_all(points)
  points.map { |p| p.floor }
end

def rotate60(point)
  x = point.x
  y = point.y
  V2.new(
    (x * COS60 - y * SIN60),
    (y * COS60 + x * SIN60))
end

def rotate_all60(points)
  points.map do |p|
    rotate60(p)
  end
end

HEXES = []
HEXES[0] = hex_f()
HEXES[1] = rotate_all60(HEXES[0])
HEXES[2] = rotate_all60(HEXES[1])
HEXES[3] = rotate_all60(HEXES[2])
HEXES[4] = rotate_all60(HEXES[3])
HEXES[5] = rotate_all60(HEXES[4])

def load_png(filename)
  img = ChunkyPNG::Image.from_file(filename)

  height = img.dimension.height
  width  = img.dimension.width

  a = []

  width.times do |col|
    a[col] ||= []
    height.times do |row|
      pixel = img[col, row]
      a[col][row] = Pix.new(ChunkyPNG::Color.r(pixel), ChunkyPNG::Color.g(pixel), ChunkyPNG::Color.b(pixel))
    end
  end

  return a, height, width
end

def to_color(pix)
  ChunkyPNG::Color.rgba(pix.r, pix.g, pix.b, 255)
end

def load_hexes(img, center)
  HEXES.map do |coords|
    shift_all(round_all(coords), center).map do |p|
      to_color(img[p.x][p.y])
    end
  end
end

def save_hex(hex, img, height, width, center)
  hex.zip(round_all(shift_all(HEXES[0], center))).each do |(color, p)|
    if p.x >= 0 && p.x < width && p.y >= 0 && p.y < height
      img[p.x,p.y] = color
    end
  end
end

def grid(height, width)
  grid = []
  row = 0
  row_index = 0
  while (row < height + 2*SIZE)
    col = (row_index % 2) * HEIGHT
    while (col < width + 2*HEIGHT)
      grid << V2.new(col, row)
      col += 2*HEIGHT
    end
    row += 1.5*SIZE
    row_index += 1
  end
  grid
end

a, height, width = load_png("cat.png")

center = V2.new(40, 40)

height = 256
width = 256

hexes = load_hexes(a, center)
png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

grid(height, width).each.with_index do |center, index|
  save_hex(hexes[index % 6], png, height, width, center)
end


# rotated = shift_all(round_all(HEXES[1]), shift(center, V2.new(0, 2*SIZE)))
# origin = shift_all(round_all(HEXES[0]), center)
#
# origin.zip(rotated).each do |(o, r)|
#   pix = a[o.x][o.y]
#   png[r.x,r.y] = to_color(pix)
# end
#
# rotated = shift_all(round_all(HEXES[2]), shift(center, V2.new(0, 4*SIZE)))
# origin.zip(rotated).each do |(o, r)|
#   pix = a[o.x][o.y]
#   png[r.x,r.y] = to_color(pix)
# end

png.save('cat1.png')
