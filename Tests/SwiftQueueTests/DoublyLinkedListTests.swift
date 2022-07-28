import XCTest
@testable import SwiftQueue

final class DoublyLinkedListTests: XCTestCase {

  var linkedList: DoublyLinkedList<Int>!

  override func setUp() async throws {
    linkedList = DoublyLinkedList<Int>()
  }

  override func tearDown() async throws {
    linkedList = nil
  }

  // MARK: - Logic

  func testEmpty() throws {
    try checkNodes(expect: [])
  }

  func testInsertSingle() throws {
    let element = 1

    linkedList.insert(element)

    try checkNodes(expect: [element])
  }

  func testInsertSingleWithCopying() throws {
    let element = 1

    let ref = linkedList

    linkedList.insert(element)

    try checkNodes(expect: [element])
  }

  func testInsert() throws {
    let elements = [1, 5, 6]

    elements.reversed().forEach { linkedList.insert($0) }

    try checkNodes(expect: elements)
  }

  func testInsertWithCopying() throws {
    let elements = [1, 5, 6, 2, 4]

    linkedList.insert(elements[4])
    linkedList.insert(elements[3])

    let ref = linkedList

    elements[0..<3].reversed().forEach { linkedList.insert($0) }

    try checkNodes(expect: elements)
  }

  func testAppendSingle() throws {
    let element = 1

    linkedList.append(element)

    try checkNodes(expect: [element])
  }

  func testAppend() throws {
    let elements = [1, 2, 5, 7, 3]

    linkedList.append(elements[0])
    linkedList.append(elements[1])

    let ref = linkedList

    elements[2...].forEach { linkedList.append($0) }

    try checkNodes(expect: elements)
  }

  func testRemoveSingle() throws {
    let element = 1
    linkedList.insert(element)

    let result = linkedList.removeFirst()
    XCTAssertEqual(result, element)

    try checkNodes(expect: [])
  }

  func testRemoveFirst() throws {
    var elements = [1, 2, 5]
    elements.forEach { linkedList.append($0) }

    while linkedList.isEmpty == false {
      XCTAssertFalse(elements.isEmpty)
      let result = linkedList.removeFirst()
      XCTAssertEqual(result, elements.removeFirst())
    }

    try checkNodes(expect: [])
  }

  func testRemoveFirstFromEmpty() throws {
    let result = linkedList.removeFirst()

    XCTAssertNil(result)
    try checkNodes(expect: [])
  }

  private weak var nullifyTestNodeHead: DoublyLinkedList<Int>.Node<Int>?
  private weak var nullifyTestNodeTail: DoublyLinkedList<Int>.Node<Int>?

  func testNullify() throws {
    let elements = Array(repeating: 1, count: 5_000_000)
    elements.forEach { linkedList.insert($0) }

    if case .node(let node) = linkedList.startIndex {
      nullifyTestNodeHead = node
    } else {
      XCTFail()
    }

    if case .end(let previous) = linkedList.endIndex {
      nullifyTestNodeTail = previous
    } else {
      XCTFail()
    }

    XCTAssertNotNil(nullifyTestNodeHead)
    XCTAssertNotNil(nullifyTestNodeTail)
    linkedList = nil
    XCTAssertNil(linkedList)
    XCTAssertNil(nullifyTestNodeHead)
    XCTAssertNil(nullifyTestNodeTail)
  }

  private func checkNodes(list: DoublyLinkedList<Int>, expect elements: [Int]) throws {
    let count = elements.count

    XCTAssertEqual(list.count, count)

    if count == 0 {
      XCTAssertTrue(list.isEmpty)
      XCTAssertNil(list.first)
      XCTAssertEqual(list.startIndex, list.endIndex)
      XCTAssertEqual(list.startIndex, .empty)
      XCTAssertEqual(list.endIndex, .empty)
      XCTAssertNil(list.last)
      return
    }

    if count == 1 {

      XCTAssertEqual(list.first, elements[0])
      XCTAssertEqual(list.last, elements[0])

      if case .node(let node) = list.startIndex {
        XCTAssertNil(node.previous)
        XCTAssertNil(node.next)
        XCTAssertEqual(node.value, elements[0])
      } else {
        XCTFail()
      }

      if case .end(let last) = list.endIndex {
        XCTAssertNil(last.next)
        XCTAssertNil(last.previous)
        XCTAssertEqual(last.value, elements[0])
      } else {
        XCTFail()
      }
      return
    }

    if count > 1 {

      XCTAssertEqual(list.first, elements[0])
      XCTAssertEqual(list.last, elements.last)

      if case .node(let node) = list.startIndex {
        XCTAssertNil(node.previous)
        XCTAssertNotNil(node.next)
        XCTAssertEqual(node.value, elements[0])
      } else {
        XCTFail()
      }

      if case .end(let last) = list.endIndex {
        XCTAssertNil(last.next)
        XCTAssertNotNil(last.previous)
        XCTAssertEqual(last.value, elements.last)
      } else {
        XCTFail()
      }
    }

    if count > 2 {
      var i = list.index(after: list.startIndex)

      for e in elements[1...elements.count - 2] {
        if case .node(let node) = i {
          XCTAssertNotNil(node.previous)
          XCTAssertNotNil(node.next)
          XCTAssertEqual(node.value, e)
        } else {
          XCTFail()
        }
        i = list.index(after: i)
      }

      i = list.index(before: list.endIndex)

      for e in elements[1...elements.count - 2].reversed() {
        i = list.index(before: i)
        if case .node(let node) = i {
          XCTAssertNotNil(node.previous)
          XCTAssertNotNil(node.next)
          XCTAssertEqual(node.value, e)
        } else {
          XCTFail()
        }
      }
    }
  }

  private func checkNodes(expect elements: [Int]) throws {
    try checkNodes(list: linkedList, expect: elements)
  }

  // MARK: - Perfomance

  func testInsertPerfomance() throws {
    let elements = Array(repeating: 1, count: 5_000_000)

    measure {
      elements.forEach { linkedList.insert($0) }
    }
  }

  func testAppendPerfomance() throws {
    let elements = Array(repeating: 1, count: 5_000_000)

    measure {
      elements.forEach { linkedList.append($0) }
    }
  }

  func testRemoveFirstPerfomance() throws {
    let elements = Array(repeating: 1, count: 5_000_000)
    elements.forEach { linkedList.insert($0) }

    measure {
      while true {
        if linkedList.removeFirst() == nil { break }
      }
    }
  }

  // MARK: - Traversing

  func testForInCorrectElements() throws {
    let elements = [0, 1, 2, 3, 4]
    elements.forEach { linkedList.append($0) }
    var result: [Int] = []

    for element in linkedList { result.append(element) }

    XCTAssertEqual(result, elements)
  }

  // MARK: - ArrayLiteral

  func testInitWithLiteral() throws {
    linkedList = nil
    linkedList = [0, 1, 2, 3, 4, 5]

    for element in linkedList.enumerated() {
      XCTAssertEqual(element.element, element.offset)
    }
  }

  // MARK: - Value-type Semantics

  func testValueTypeSemantics() throws {
    var list1: DoublyLinkedList = [1, 2]

    var list2 = list1
    list2.append(3)
    list1.removeFirst()

    XCTAssertNotEqual(list1, list2)
    XCTAssertEqual(list1.count, 1)
    XCTAssertEqual(list2.count, 3)
  }
}
