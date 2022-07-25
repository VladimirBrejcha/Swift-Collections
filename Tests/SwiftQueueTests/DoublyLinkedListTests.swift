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

  func testInsert() throws {
    let element = 1
    let element2 = 5

    linkedList.insert(element)
    linkedList.insert(element2)

    XCTAssertEqual(linkedList.first, element2)
    XCTAssertEqual(linkedList.last, element)
    XCTAssertEqual(linkedList.count, 2)
  }

  func testAppend() throws {
    let element = 1
    let element2 = 5

    linkedList.append(element)
    linkedList.append(element2)

    XCTAssertEqual(linkedList.first, element)
    XCTAssertEqual(linkedList.last, element2)
    XCTAssertEqual(linkedList.count, 2)
  }

  func testRemoveFirst() throws {
    let element = 1
    linkedList.insert(element)

    let result = linkedList.removeFirst()

    XCTAssertEqual(result, element)
    XCTAssertNil(linkedList.first)
    XCTAssertTrue(linkedList.isEmpty)
  }

  func testRemoveFirstFromEmpty() throws {

    let result = linkedList.removeFirst()

    XCTAssertNil(result)
    XCTAssertTrue(linkedList.isEmpty)
    XCTAssertNil(linkedList.first)
  }

  func testNullify() throws {
    let elements = Array(repeating: 1, count: 5_000_000)
    elements.forEach { linkedList.insert($0) }

    linkedList = nil
    XCTAssertNil(linkedList)
  }

  // MARK: - Perfomance

  func testInsertPerfomance() throws {
    let elements = Array(repeating: 1, count: 5_000_000)

    measure {
      elements.forEach { linkedList.insert($0) }
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
    var list1 = DoublyLinkedList<Int>()
    list1.append(1)
    list1.append(2)

    var list2 = list1
    list2.append(3)
    list1.removeFirst()

    XCTAssertNotEqual(list1, list2)
    XCTAssertEqual(list1.count, 1)
    XCTAssertEqual(list2.count, 3)
  }
}
