public struct DoublyLinkedList<Element>:
  BidirectionalCollection,
  MutableCollection,
  CustomStringConvertible,
  ExpressibleByArrayLiteral
{
  // MARK: - Node

  public class Node<Value>: CustomStringConvertible {

    public var value: Value
    public var next: Node?
    public weak var previous: Node?

    public init(value: Value, next: Node? = nil, previous: Node? = nil) {
      self.value = value
      self.next = next
      self.previous = previous
    }

    deinit {
      // https://forums.swift.org/t/deep-recursion-in-deinit-should-not-happen/54987
      // avoid deep recursion in deinit by tearing down the rest of the
      // list ourselves if it's uniquely referenced
      while isKnownUniquelyReferenced(&next) {
        let temp = next
        next = temp?.next
        temp?.next = nil
      }
    }

    public var description: String {
      "\(optional: previous?.value) <- \(value) -> \(optional: next?.value)"
    }
  }

  // MARK: - LinkedList

  private var head: Node<Element>?
  private var tail: Node<Element>?

  public mutating func insert(_ element: Element) {
    copy()
    let newHead = Node(value: element, next: head)
    head?.previous = newHead
    head = newHead
    if tail == nil {
      tail = head
    }
  }

  public mutating func append(_ element: Element) {
    copy()
    if head == nil {
      insert(element)
    } else {
      tail?.next = Node(value: element)
      tail?.previous = tail
      tail = tail?.next
    }
  }

  @discardableResult
  public mutating func removeFirst() -> Element? {
    copy()
    defer {
      head = head?.next
      if head == nil { tail = nil }
    }
    return head?.value
  }

  // MARK: - ExpressibleByArrayLiteral

  public init(arrayLiteral elements: Element...) {
    elements.forEach { append($0) }
  }

  // MARK: - BidirectionalCollection

  public var startIndex: Index {
    if let head = head {
      return Index.node(head)
    } else {
      return .empty
    }
  }

  public var endIndex: Index {
    if let tail = tail {
      return .end(previous: tail)
    }
    return .empty
  }

  public func index(after idx: Index) -> Index {
    switch idx {
    case .end(let previous):
      return .end(previous: previous)
    case .node(let node):
      if let next = node.next {
        return .node(next)
      }
      return .end(previous: node)
    case .empty:
      return .empty
    }
  }

  public func index(before idx: Index) -> Index {
    switch idx {
    case .end(let previous):
      return .node(previous)
    case .node(let node):
      if let prev = node.previous {
        return .node(prev)
      }
      return .empty
    case .empty:
      return .empty
    }
  }

  public enum Index: Comparable {
    public static func < (lhs: Index, rhs: Index) -> Bool {
      if lhs == rhs { return false }
      if case .end = lhs { return false }
      if case .end = rhs { return true }
      if case .node(let lhsNode) = lhs, case .node(let rhsNode) = rhs {
        let nodes = sequence(first: lhsNode) { $0?.next }
        return nodes.contains { $0 === rhsNode }
      }
      return false
    }

    public static func == (lhs: Index, rhs: Index) -> Bool {
      switch (lhs, rhs) {
      case (.empty, .empty), (.end, .end):
        return true
      case (.node(let lhsNode), .node(let rhsNode)):
        return lhsNode.next === rhsNode.next
        && lhsNode.previous === rhsNode.previous
      default:
        return false
      }
    }

    case end(previous: Node<Element>)
    case node(Node<Element>)
    case empty
  }

  // MARK: - MutableCollection

  public subscript(position: Index) -> Element {
    _read {
      if case .node(let node) = position {
        yield node.value
      } else {
        fatalError()
      }
    }
    set(newValue) {
      if case .node(let node) = position {
        node.value = newValue
      }
    }
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    if let head = head {
      var next: Node? = head
      var str: String = "["
      while next != nil {
        str.append("\(optional: next?.value)")
        next = next?.next
        if next != nil { str.append("-") }
      }
      str.append("]")
      return str
    }
    return "[EmptyLinkedList]"
  }

  // MARK: - Value Type Semantics

  private mutating func copy() {
     guard !isKnownUniquelyReferenced(&head) else {
        return
     }

     guard var oldHead = head else {
        return
     }

     head = Node(value: oldHead.value)
     var newHead = head

     while let nextOldHead = oldHead.next {
        newHead!.next = Node(value: nextOldHead.value)
        newHead = newHead!.next

        oldHead = nextOldHead
     }

     tail = newHead
  }
}

// MARK: - Equatable

extension DoublyLinkedList: Equatable where Element: Equatable {
  public static func == (lhs: DoublyLinkedList<Element>, rhs: DoublyLinkedList<Element>) -> Bool {
    var lhsNext = lhs.head
    var rhsNext = rhs.head
    repeat {
      if lhsNext == nil && rhsNext == nil { return true }
      if lhsNext?.value != rhsNext?.value { return false }
      lhsNext = lhsNext?.next
      rhsNext = rhsNext?.next
    } while true
  }
}

// MARK: - Hashable

extension DoublyLinkedList: Hashable where Element: Hashable {
  public func hash(into hasher: inout Hasher) {
    var next = head
    while next != nil {
      hasher.combine(next?.value)
      next = next?.next
    }
  }
}
