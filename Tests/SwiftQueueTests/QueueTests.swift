import XCTest
@testable import SwiftQueue

final class QueueTests: XCTestCase {

  var queue: Queue<Int>!

  override func setUp() async throws {
    queue = Queue<Int>()
  }

  override func tearDown() async throws {
    queue = nil
  }

  // MARK: - Logic

  func testEnqueue() throws {
    let element = 1

    queue.enqueue(element)

    XCTAssertEqual(queue.first, element)
  }

  func testDequeue() throws {
    let element = 1
    queue.enqueue(element)

    let result = queue.dequeue()

    XCTAssertEqual(result, element)
    XCTAssertNil(queue.first)
    XCTAssertTrue(queue.isEmpty)
  }

  func testDequeueEmpty() throws {

    let result = queue.dequeue()

    XCTAssertNil(result)
    XCTAssertTrue(queue.isEmpty)
    XCTAssertNil(queue.first)
  }

  // MARK: - Perfomance

  func testNullify() throws {
    let elements = Array(repeating: 1, count: 5_000_000)
    elements.forEach { queue.enqueue($0) }

    queue = nil
    XCTAssertNil(queue)
  }

  func testEnqueuePerfomance() throws {
    let elements = Array(repeating: 1, count: 5_000_000)

    measure {
      elements.forEach { queue.enqueue($0) }
    }
  }

  func testDequeuePerfomance() throws {
    let elements = Array(repeating: 1, count: 5_000_000)
    elements.forEach { queue.enqueue($0) }

    measure {
      while true {
        if queue.dequeue() == nil { break }
      }
    }
  }

  // MARK: - Traversing

  func testForInCorrectElements() throws {
    let elements = [0, 1, 2, 3, 4]
    elements.forEach { queue.enqueue($0) }
    var result: [Int] = []

    for element in queue { result.append(element) }

    XCTAssertEqual(result, elements)
  }

  // MARK: - ArrayLiteral

  func testInitWithLiteral() throws {
    queue = nil
    queue = [0, 1, 2, 3, 4, 5]

    for element in queue.enumerated() {
      XCTAssertEqual(element.element, element.offset)
    }
  }

  // MARK: - Value Type Semantics

  func testValueTypeSemantics() throws {
    var queue1: Queue = [1, 2]

    var queue2 = queue1
    queue2.enqueue(3)
    queue1.dequeue()

    XCTAssertNotEqual(queue1, queue2)
    XCTAssertEqual(queue1.count, 1)
    XCTAssertEqual(queue2.count, 3)
  }
}
