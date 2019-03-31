require 'chunky_png'

SQRT3 = (3**(1.0/2))
SIZE = 20
HEIGHT = SQRT3/2 * SIZE

Pix = Struct.new(:r, :g, :b)
class Point < Struct.new(:x, :y)
  def to_s
    "(#{x}, #{y})"
  end
end

def hex(center)
  result = []

  f = -> (y, sa, sb) {
    sa * SQRT3 * (y + sb * SIZE)
  }

  (SIZE/2..SIZE).each do |row|
    limit = (-SQRT3 * (row - SIZE)).round
    (-limit..limit).each do |col|
      result << Point.new(center.x + col, center.y + row)
    end
  end

  (-SIZE/2..SIZE/2).each do |row|
    (-HEIGHT.round..HEIGHT.round).each do |col|
      result << Point.new(center.x + col, center.y + row)
    end
  end

  (-SIZE..-SIZE/2).each do |row|
    limit = (SQRT3 * (row + SIZE)).round
    (-limit..limit).each do |col|
      result << Point.new(center.x + col, center.y + row)
    end
  end

  result
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

# width.times do |col|
#   height.times do |row|
#     pix = a[col][row]
#     png[col,row] = ChunkyPNG::Color.rgba(pix.r, pix.g, pix.b, 255)
#   end
# end

hex(Point.new(110, 110)).each do |p|
  pix = a[p.x][p.y]
  png[p.x,p.y] = ChunkyPNG::Color.rgba(0, pix.g, pix.b, 255)
end

hex(Point.new(140, 140)).each do |p|
  pix = a[p.x][p.y]
  png[p.x,p.y] = ChunkyPNG::Color.rgba(pix.r, 0, pix.b, 255)
end

png.save('cat1.png')
