import XCTest
@testable import SwiftQueue

final class TrivialQueueTests: XCTestCase {

  var queue: TrivialQueue<Int>!

  override func setUp() async throws {
    queue = TrivialQueue<Int>()
  }

  override func tearDown() async throws {
    queue = nil
  }

  // MARK: - Logic

  func testEnqueue() throws {
    let element = 1

    queue.enqueue(element)

    XCTAssertEqual(queue.storage.count, 1)
    XCTAssertEqual(queue.storage[0], 1)
  }

  func testDequeue() throws {
    let element = 1
    queue.enqueue(element)

    let result = queue.dequeue()

    XCTAssertEqual(result, element)
    XCTAssertEqual(queue.storage.count, 0)
  }

  func testDequeueEmpty() throws {

    let result = queue.dequeue()

    XCTAssertNil(result)
    XCTAssertEqual(queue.storage.count, 0)
  }

  // MARK: - Perfomance

  func testEnqueuePerfomance() throws {
    let elements = Array(repeating: 1, count: 500_000)

    measure { // about 0.063 seconds
      elements.forEach { queue.enqueue($0) }
    }
  }

  func testDequeuePerfomance() throws {
    let elements = Array(repeating: 1, count: 500_000)
    elements.forEach { queue.enqueue($0) }

    measure { // about 2 seconds
      while true {
        if queue.dequeue() == nil { break }
      }
    }
  }
}
