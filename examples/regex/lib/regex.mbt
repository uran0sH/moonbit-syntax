enum Token {
  EOS
  ANY
  AT_BOL
  AT_EOL
  CCL_END
  CCL_START
  CLOSE_CURLY
  CLOSE_PAREN
  CLOSURE
  DASH
  END_OF_INPUT
  L
  OPEN_CURLY
  OPEN_PAREN
  OPTIONAL
  OR
  PLUS_CLOSE
}

struct Lexer {
  data: String
  mut pos: Int
  mut token: Token
  mut is_escaped: Bool
}

func advance(self: Lexer) {
  if self.data[self.pos] == '\\' {
    self.is_escaped = not(self.is_escaped)
    self.pos = self.pos + 1
  }
  ()
}

func to_ascii_lower(s: String) -> String {
  var result = array_make(10, 0)
  var index = 0
  let l = s.length()
  while index < l {
    if s[index].compare('A') > 0 && s[index].compare('Z') < 0 {
      result[index] = (s[index].to_int() - 'A'.to_int()) + 'a'.to_int()
      result[index].print()
      '\n'.print()
    }
    index = index + 1
  }
  ""
}

func handle_escape(self: Lexer) {

}

func init {
  to_ascii_lower("ABC").print()
}