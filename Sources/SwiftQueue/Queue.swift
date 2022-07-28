public struct Queue<Element>:
  BidirectionalCollection,
  MutableCollection,
  ExpressibleByArrayLiteral,
  CustomStringConvertible,
  CustomReflectable
{
  private var linkedList: DoublyLinkedList<Element> = []

  public mutating func enqueue(_ element: Element) {
    linkedList.append(element)
  }

  @discardableResult
  public mutating func dequeue() -> Element? {
    linkedList.removeFirst()
  }

  // MARK: - MutableCollection

  public subscript(position: DoublyLinkedList<Element>.Index) -> Element {
    _read {
      yield linkedList[position]
    }
    set(newValue) {
      linkedList[position] = newValue
    }
  }

  // MARK: - Collection

  public typealias Index = DoublyLinkedList<Element>.Index

  public var startIndex: Index {
    linkedList.startIndex
  }

  public var endIndex: Index {
    linkedList.endIndex
  }

  public func index(after i: Index) -> Index {
    linkedList.index(after: i)
  }

  public func index(before i: Index) -> Index {
    linkedList.index(before: i)
  }

  // MARK: - ExpressibleByArrayLiteral

  public init(arrayLiteral elements: Element...) {
    elements.forEach { enqueue($0) }
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    if linkedList.isEmpty {
      return "[EmptyQueue]"
    }
    return linkedList.description
  }

  // MARK: - CustomReflectable

  public var customMirror: Mirror {
    Mirror(
      self,
      unlabeledChildren: self,
      displayStyle: .collection
    )
  }
}

// MARK: - Equatable

extension Queue: Equatable where Element: Equatable {
  public static func == (lhs: Queue<Element>, rhs: Queue<Element>) -> Bool {
    lhs.linkedList == rhs.linkedList
  }
}

// MARK: - Hashable

extension Queue: Hashable where Element: Hashable {
  public func hash(into hasher: inout Hasher) {
    linkedList.hash(into: &hasher)
  }
}
