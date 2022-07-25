extension DefaultStringInterpolation {
  mutating func appendInterpolation<T>(optional: T?) {
    if let optional = optional {
      appendInterpolation(optional)
    } else {
      appendLiteral("nil")
    }
  }
}
