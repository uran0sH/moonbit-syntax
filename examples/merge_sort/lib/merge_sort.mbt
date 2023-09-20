func merge(xs : List[Int], ys : List[Int]) -> List[Int] {
  fn mrg(xs : List[Int], ys : List[Int]) {
    match (xs, ys) {
      (Nil, ys) => ys
      (xs, Nil) => xs
      (Cons(x, xs), Cons(y, ys)) =>
        if x < y {
          Cons(x, mrg(xs, Cons(y, ys)))
        } else {
          Cons(y, mrg(Cons(x, xs), ys))
        }
    }
  }

  mrg(xs, ys)
}

pub func merge_sort(list : List[Int]) -> List[Int] {
  fn merge_all(xs : List[Int], ys : List[Int]) -> List[Int] {
    match (xs, ys) {
      (xs, Nil) => xs
      (xs, Cons(y, ys)) => merge_all(merge(xs, Cons(y, Nil)), ys)
    }
  }

  merge_all(Nil, list)
}

/// construct List from Array.
pub func stream[T](self : Array[T]) -> List[T] {
  fn go(idx : Int) -> List[T] {
    if idx == self.length() {
      Nil
    } else {
      Cons(self[idx], go(idx + 1))
    }
  }

  go(0)
}

/// convert list to string
func to_string[T : Show](self : List[T]) -> String {
  fn go(ls : List[T]) {
    match ls {
      Nil => ""
      Cons(x, Nil) => "\(x)"
      Cons(x, xs) => "\(x), " + go(xs)
    }
  }

  "[" + go(self) + "]"
}

func init {
  let l1 = [2, 4, 3, 5, 6, 1, 11, 10, 7, 14, 20, 15, 13, -1, 0].stream()
  let sorted_l = merge_sort(l1)
  println(sorted_l.to_string())
  let l2 = [].stream()
  let sorted_l = merge_sort(l2)
  println(sorted_l.to_string())
}

