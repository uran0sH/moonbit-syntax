pub func quick_sort(arr: Array[Int]) {
  sort_helper(arr, 0, arr.length() - 1)
}

func sort_helper(arr: Array[Int], s : Int, e : Int) {
  if s < e {
    let p = partition(arr, s, e)
    sort_helper(arr, s, p - 1)
    sort_helper(arr, p + 1, e)
  }
}

func partition(arr: Array[Int], s : Int, e : Int) -> Int {
  var i = s + 1
  var j = e
  let pv = arr[s]
  while true {
    while i <= e && arr[i] < pv {
      i = i + 1
    }
    while j >= s && arr[j] > pv {
      j = j - 1
    }
    if i >= j {
      break
    }
    swap(arr, i, j)
  }
  swap(arr, s, j)
  return j
}

func swap(arr: Array[Int], i : Int, j : Int) {
  let temp = arr[i]
  arr[i] = arr[j]
  arr[j] = temp
}

func quick_sort_func(l : List[Int]) -> List[Int] {
  fn sort(l: List[Int]) -> List[Int] {
    match l {
      Nil => Nil
      Cons(p, xs) => {
        sort(xs.filter(fn(x) {x < p})).concat(Cons(p, sort(xs.filter(fn(x) {x >= p}))))
      }
    }
  }
  sort(l)
}

/// returns the List of those elements that satisfy the predicate.
func filter[T](self: List[T], predicate: (T) -> Bool) -> List[T] {
  match self {
    Nil => Nil
    Cons(x, xs) =>
      if predicate(x) {
        Cons(x, filter(xs, predicate))
      } else {
        filter(xs, predicate)
      }
  }
}


pub func concat[X](self: List[X], ys: List[X]) -> List[X] {
  match self {
    Nil => ys
    Cons(x, rest) => Cons(x, concat(rest, ys))
  }
}

func stream[T](self: Array[T]) -> List[T] {
  fn go(idx: Int) -> List[T] {
    if idx == self.length() { Nil } else { Cons(self[idx], go(idx + 1)) }
  }

  go(0)
}

/// convert list to string
func to_string[T : Show](self : List[T]) -> String {
  fn go(ls : List[T]){
    match ls {
      Nil => ""
      Cons(x,Nil) => "\(x)"
      Cons(x,xs) => "\(x), " + go(xs)
    }
  }
  "[" + go(self) + "]"
}


func init {

}

