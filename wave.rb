
def wave_down(from:, to:, n:)
  bg = Math::PI * 0.5
  ed = Math::PI * 1.5
  st = (ed - bg) / n
  p  = from - to
  (bg..ed).step(st).map do |i|
    x = (1 + Math::sin(i)) / 2.0
    to + x * p
  end
end

def wave_up(from:, to:, n:)
  bg = - Math::PI / 2
  ed = + Math::PI / 2
  st = (ed - bg) / n
  p  = to - from
  (bg..ed).step(st).map do |i|
    x = (1 + Math::sin(i)) / 2.0
    from + x * p
  end
end

def stay(on:, n:)
  [on] * n
end

def linear_play(from, to, length:1, note:60)
  play(
    note,
    attack_level:  from,
    decay_level:   from,
    sustain_level: to,
    attack:        0,
    decay:         0,
    release:       0,
    sustain:       length,
  )
  sleep length
  return to # for Enumerable#inject convenience
end

def cause w
  use_synth w.synth
  lmin = 0.0 # last min
  live_loop w.synth do
    cmax = w.max # current max
    cmin = w.min # current min

    array = [
      wave_up(  n: w.up,      from: lmin, to: cmax),
      stay(     n: w.ceiling,             on: cmax),
      wave_down(n: w.down,    from: cmax, to: cmin),
      stay(     n: w.floor,               on: cmin),
    ].flatten

    lmin = array.inject{ |a,b| linear_play a,b }
  end
end

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

class Wave
  def initialize(synth:, min:, max:, up:, ceiling:, down:, floor:)
    @synth   = synth
    @min     = min
    @max     = max
    @up      = up
    @ceiling = ceiling
    @down    = down
    @floor   = floor
  end

  attr_accessor :synth

  def setter v
    instance_variable_set "@#{__callee__}".chop, v
  end
  alias :min=     :setter
  alias :max=     :setter
  alias :up=      :setter
  alias :ceiling= :setter
  alias :down=    :setter
  alias :floor=   :setter
  undef :setter

  def getter
    random_pick instance_variable_get "@#{__callee__}"
  end
  alias :min     :getter
  alias :max     :getter
  alias :up      :getter
  alias :ceiling :getter
  alias :down    :getter
  alias :floor   :getter
  undef :getter

  def random_pick(r, step:0.1)
    r.step(step).to_a.choose
  end
end

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

use_random_seed Time.now.to_i
use_bpm 60

cause Wave.new(
  synth:   :noise,
  min:     0.1.. 0.3,
  max:     0.5.. 0.8,
  up:      2  .. 5,
  ceiling: 8  ..12,
  down:    3  .. 5,
  floor:   8  ..10,
)

cause Wave.new(
  synth:   :bnoise,
  min:     0.1.. 0.3,
  max:     0.7.. 1.0,
  up:      2  .. 5,
  ceiling: 8  ..12,
  down:    3  .. 5,
  floor:   8  ..10,
)

