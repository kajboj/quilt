require 'chunky_png'

SQRT3 = (3**(1.0/2))
SIZE = 20 
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

HEXF0 = hex_f()
HEXF1 = rotate_all60(HEXF0)
HEXF2 = rotate_all60(HEXF1)
HEXF3 = rotate_all60(HEXF2)
HEXF4 = rotate_all60(HEXF3)
HEXF5 = rotate_all60(HEXF4)

img = ChunkyPNG::Image.from_file("cat.png")

height = img.dimension.height
width  = img.dimension.width

a = []

width.times do |col|
  a[col] ||= []
  height.times do |row|
    pixel = img[col,row]
    a[col][row] = Pix.new(ChunkyPNG::Color.r(pixel), ChunkyPNG::Color.g(pixel), ChunkyPNG::Color.b(pixel))
  end
end

png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

center = V2.new(110, 110)

shift_all(round_all(HEXF0), center).each do |p|
  pix = a[p.x][p.y]
  png[p.x,p.y] = ChunkyPNG::Color.rgba(pix.r, pix.g, pix.b, 255)
end

rotated = shift_all(round_all(HEXF1), shift(center, V2.new(0, 2*SIZE)))
origin = shift_all(round_all(HEXF0), center)

origin.zip(rotated).each do |(o, r)|
  pix = a[o.x][o.y]
  png[r.x,r.y] = ChunkyPNG::Color.rgba(pix.r, pix.g, pix.b, 255)
end

rotated = shift_all(round_all(HEXF2), shift(center, V2.new(0, 4*SIZE)))
origin.zip(rotated).each do |(o, r)|
  pix = a[o.x][o.y]
  png[r.x,r.y] = ChunkyPNG::Color.rgba(pix.r, pix.g, pix.b, 255)
end

png.save('cat1.png')
