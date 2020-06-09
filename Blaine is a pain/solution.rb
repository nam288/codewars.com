SIGN = [-1, 0, 1]

$D = SIGN.to_a.flat_map {|x| SIGN.map {|y| [x,y]}} - [[0, 0]]
$ids = {}

def get_cell x, y
  0 <= x && x < $N_ROW && 0 <= y && y < $N_COL[x] ? $t[x][y] : nil
end

def get_cell_by_dir(dir, x, y, v)
  if dir == 'L'
    nx, ny = x, y-1
  elsif dir == 'R'
    nx, ny = x, y+1
  elsif dir == 'U'
    nx, ny = x-1, y
  else
    nx, ny = x+1, y
  end
  get_cell(nx, ny) == v
end

def get_track x, y
  $tracks[x][y]
end

def move_by(from:, dir:, offset: )
  (dir == 1 ? from + offset : from - offset) % $cnt_track
end

class Track
  attr_accessor :x, :y, :v, :type, :neighbours, :id, :memoize, :occupies
  def initialize(x, y)
    @x, @y, @v = x, y, get_cell(x, y)
    @type = @v == 'S' ? :station : @v == ' ' ? :space : :norm
    @id = []
    @occupies = ''
  end

  def add train
    raise StandardError unless @occupies == ''
    @occupies = train.name
  end

  def remove train
    raise StandardError unless @occupies == train.name
    @occupies = ''
  end

  def find_neighbours
    return @neighbours = [] if @type == :space
    dir = v == '-' ? [[0, -1], [0, 1]] : v == '|' ? [[-1, 0], [1, 0]] : $D

    r =  dir.map { |dx, dy|
      next_cell = get_cell(nx = x + dx, ny = y + dy)
      next_cell && next_cell != ' ' ? [nx, ny] : nil
    }.compact

    if v == "\\"
      return @neighbours = [[[x-1, y], [x, y+1]]] if get_cell_by_dir('U', x, y, '|') and get_cell_by_dir('R', x, y, '-')
      return @neighbours = [[[x+1, y], [x, y-1]]] if get_cell_by_dir('D', x, y, '|') and get_cell_by_dir('L', x, y, '-')
      return @neighbours = [[[x-1, y-1], [x, y+1]]] if get_cell(x-1, y-1) == "\\" and get_cell(x, y+1) == "-"
      return @neighbours = [[[x-1, y-1], [x+1, y+1]]] if get_cell(x-1, y-1) == "\\" and get_cell(x+1, y+1) == "\\"
      return @neighbours = [[[x-1, y-1], [x+1, y]]] if get_cell(x-1, y-1) == "\\" and get_cell(x+1, y) == "|"
      return @neighbours = [[[x+1, y+1], [x, y-1]]] if get_cell(x+1, y+1) == "\\" and get_cell(x, y-1) == "-"
      return @neighbours = [[[x+1, y+1], [x-1, y]]] if get_cell(x+1, y+1) == "\\" and get_cell(x-1, y) == "|"
    end

    if v == "/"
      return @neighbours = [[[x-1, y], [x, y-1]]] if get_cell_by_dir('U', x, y, '|') and get_cell_by_dir('L', x, y, '-')
      return @neighbours = [[[x+1, y], [x, y+1]]] if get_cell_by_dir('D', x, y, '|') and get_cell_by_dir('R', x, y, '-')
      return @neighbours = [[[x+1, y-1], [x, y+1]]] if get_cell(x+1, y-1) == "/" and get_cell(x, y+1) == "-"
      return @neighbours = [[[x+1, y-1], [x-1, y]]] if get_cell(x+1, y-1) == "/" and get_cell(x-1, y) == "|"
      return @neighbours = [[[x-1, y+1], [x, y-1]]] if get_cell(x-1, y+1) == "/" and get_cell(x, y-1) == "-"
      return @neighbours = [[[x-1, y+1], [x+1, y-1]]] if get_cell(x-1, y+1) == "/" and get_cell(x+1, y-1) == "/"
      return @neighbours = [[[x-1, y+1], [x+1, y]]] if get_cell(x-1, y+1) == "/" and get_cell(x+1, y) == "|"
    end

    if v == "\\" or v == "/" and r.size == 4
      r.reject! {|nx, ny| $t[nx][ny] == '-' and (nx-x).abs != 0}
      return @neighbours = [r]
    end

    @neighbours = r.size == 2 ? [r] : [[r[0], r[3]], [r[1], r[2]]]
  end

  def next_track(from = nil)
    return $tracks[x][y + 1] unless from

    @neighbours.each {|pair|
      pair.each_with_index {|e, i|
        if e == [from.x, from.y]
          nxt = pair[1-i]
          return get_track(nxt[0], nxt[1])
        end
      }
    }
  end
end

class Train
  attr_accessor :name, :length, :dir, :head_id, :tail_id
  def initialize(name, pos)
    @pos, @name, @length = pos, name.downcase[0], name.size
    @dir = name[0].ord > 96 ? 1 : 0
    $ids[pos].add self
    (1...@length).each {|i| $ids[move_by(from: pos, dir: (1 - @dir), offset: i)].add self }
    @head_id, @tail_id = pos, move_by(from: pos, dir: (1 - @dir), offset: @length - 1)
    @waiting_time = 0
  end

  def remove_tail
    $ids[@tail_id].remove self if @waiting_time == 0
  end

  def move
    return @waiting_time -= 1 if @waiting_time > 0
    @tail_id = move_by(from: @tail_id, dir: @dir, offset: 1)
    @head_id = move_by(from: @head_id, dir: @dir, offset: 1)
    $ids[@head_id].add self
    @waiting_time = @length - 1 if $ids[@head_id].type == :station and @name != 'x'
  end
end

def visit
  $zero_track = $tracks.first.find { |e| e.type != :space }
  $zero_track.id <<= 0
  $ids[0] = $zero_track
  visit = Hash.new {false}
  prev = $zero_track
  visit[prev] = true
  id = 0
  curr = prev.next_track
  cnt = 1.0

  while curr != $zero_track
    curr.id <<= (id += 1)
    $ids[id] = curr
    visit[curr] = true
    cnt += curr.v == '+' ? 0.5 : 1.0
    prev, curr = curr, curr.next_track(prev)
  end

  $cnt_track = $tracks.map { |line| line.map{|track| track.id.size }.sum }.sum
end

def pre_calculate track
  $t = track.split("\n").map { |e| e.split('') }
  $N_ROW, $N_COL = $t.size, $t.map(&:size)

  $tracks = (0...$N_ROW).map {|x| (0...$N_COL[x]).map { |y| Track.new x, y }}
  $tracks.each {|line| line.each {|track| track.find_neighbours}}

  visit
end

def train_crash(track, a_train, a_train_pos, b_train, b_train_pos, limit)
  pre_calculate track

  begin
    $a_train, $b_train = Train.new(a_train, a_train_pos), Train.new(b_train, b_train_pos)
  rescue
    return 0
  end

  t = -1
  begin
    while limit > 0
      t += 1
      $a_train.remove_tail
      $b_train.remove_tail
      $a_train.move
      $b_train.move
      limit -= 1
    end
  rescue
    return t + 1
  end
  -1
end
