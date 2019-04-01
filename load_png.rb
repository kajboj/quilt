require 'chunky_png'

SQRT3 = (3**(1.0/2))
SIZE = 40
HEIGHT = SQRT3/2 * SIZE
SIN60 = SQRT3/2
COS60 = 0.5

Pix = Struct.new(:r, :g, :b)
class Point < Struct.new(:x, :y)
  def to_s
    "(#{x}, #{y})"
  end
end

def hex()
  result = []

  (SIZE/2..SIZE).each do |row|
    limit = (-SQRT3 * (row - SIZE)).floor
    (-limit..limit).each do |col|
      result << Point.new(col, row)
    end
  end

  (-SIZE/2..SIZE/2).each do |row|
    (-HEIGHT.round..HEIGHT.round).each do |col|
      result << Point.new(col, row)
    end
  end

  (-SIZE..-SIZE/2).each do |row|
    limit = (SQRT3 * (row + SIZE)).floor
    (-limit..limit).each do |col|
      result << Point.new(col, row)
    end
  end

  result
end

def hex_rotated60()
  result = []

  (SIZE/2..SIZE).each do |row|
    limit = (-SQRT3 * (row - SIZE)).floor
    (-limit..limit).each do |col|
      result << Point.new(col, row)
    end
  end

  (-SIZE/2..SIZE/2).each do |row|
    (-HEIGHT.round..HEIGHT.round).each do |col|
      result << Point.new(col, row)
    end
  end

  (-SIZE..-SIZE/2).each do |row|
    limit = (SQRT3 * (row + SIZE)).floor
    (-limit..limit).each do |col|
      result << Point.new(col, row)
    end
  end

  result
end

HEX = hex()

def shift(point, vec)
  Point.new(point.x+vec.x, point.y+vec.y)
end

def shift_all(points, vec)
  points.map { |p| shift(p, vec) }
end

def rotate60(point)
  x = point.x
  y = point.y
  Point.new(
    (x * COS60 - y * SIN60).round,
    (y * COS60 + x * SIN60).round)
end

def rotate_all60(points)
  points.map do |p|
    rotate60(p)
  end
end

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

center = Point.new(110, 110)

shift_all(HEX, center).each do |p|
  pix = a[p.x][p.y]
  png[p.x,p.y] = ChunkyPNG::Color.rgba(0, pix.g, pix.b, 255)
end

shift_all(rotate_all60(HEX), shift(center, Point.new(2*HEIGHT, 0))).each do |p|
  pix = a[p.x][p.y]
  png[p.x,p.y] = ChunkyPNG::Color.rgba(pix.r, 0, pix.b, 255)
end

shift_all(HEX, shift(center, Point.new(HEIGHT, 1.5*SIZE))).each do |p|
  pix = a[p.x][p.y]
  png[p.x,p.y] = ChunkyPNG::Color.rgba(pix.r, pix.g, 0, 255)
end

puts HEX.size
puts rotate_all60(HEX).size

png.save('cat1.png')
