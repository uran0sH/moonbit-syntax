func init {
  let arr = [6, 4, 3, 1, 5, 2, 10, 4,19, 20, 16, 17]
  @lib.quick_sort(arr)
  var index = 0
  while index < arr.length() {
    print(arr[index])
    print(",")
    index = index + 1
  }
}
