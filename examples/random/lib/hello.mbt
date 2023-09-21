pub struct Random {
  seed: Int64
  mut counter: Int64
  mut initialized: Bool
}

pub func inc_counter(self : Random) {
  self.counter = self.counter + 1L
}

func clz(x: Int) -> Int {
  var n = 32
  var x = x
  let y = x.asr(16)
  if y != 0 {
    n = n - 16
    x = y;
  }
  let y = x.asr(8)
  if y != 0 {
    n = n - 8
    x = y
  }
  let y = x.asr(4)
  if y != 0 {
    n = n - 4
    x = y
  }
  let y = x.asr(2)
  if y != 0 {
    n = n - 2
    x = y
  }
  let y = x.asr(1)
  if y != 0 {
    return n - 2
  }
  return n - x
}

func squares(ctr : Int64, key: Int64) -> Int {
  var x = ctr * key
  let y = ctr * key
  let z = y + key
  
  x = x * x + y
  x = x.lsr(32L).lor(x.lsl(32L))
  x = x * x + z
  x = x.lsr(32L).lor(x.lsl(32L))
  x = x * x + y
  x = x.lsr(32L).lor(x.lsl(32L))
  (x * x + z).lsr(32L).to_int()
}

pub func next(self : Random) -> Int {
  self.check_initialized()
  let ret = squares(self.counter, self.seed)
  self.inc_counter()
  ret
}

pub func Random::new(seed: Int64) -> Random {
  {seed, counter: 0L, initialized: false}
}

pub func check_initialized(self : Random) {
  if not(self.initialized) {
    while clz(squares(self.counter, self.seed)) > 0 {
      self.inc_counter()
    }
    self.inc_counter()
    self.initialized = true
  }
}

func init {
  let r = Random::new(3L)
  var index = 0
  while index < 6 {
    println(r.next())
    index = index + 1
  }
}
