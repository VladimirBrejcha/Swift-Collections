public struct TrivialQueue<Element> {

  private(set) var storage: [Element] = []

  public mutating func enqueue(_ element: Element) {
    storage.append(element)
  }

  public mutating func dequeue() -> Element? {
    if storage.isEmpty { return nil }
    return storage.removeFirst()
  }
}
