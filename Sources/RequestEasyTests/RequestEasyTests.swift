import XCTest
@testable import RequestEasy

class RequestHandlerTests: XCTestCase {

    // MARK: - Image Request Tests

    func testGetImage() {
        guard let url = URL(string: "https://cards.scryfall.io/large/front/d/9/d99a9a7d-d9ca-4c11-80ab-e39d5943a315.jpg?1632831210") else {
            XCTFail("Invalid URL")
            return
        }

        let requestHandler = RequestHandler()
        let expectation = self.expectation(description: "Image download should succeed")

        requestHandler.GET(url: url, type: .image) { result in
            switch result {
            case .success(let data):
                XCTAssertTrue(data is Data, "Expected data to be Data")
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    // MARK: - Content as Text Request Tests

    func testGetContentAsText() {
        guard let url = URL(string: "https://api.scryfall.com/cards/search?order=cmc&q=c%3Ared+pow%3D3") else {
            XCTFail("Invalid URL")
            return
        }

        let requestHandler = RequestHandler()
        let expectation = self.expectation(description: "Content as text download should succeed")

        requestHandler.GET(url: url, type: .contentAsText(name: "post")) { result in
            switch result {
            case .success(let data):
                XCTAssertTrue(data is [String: String], "Expected data to be [String: String]")
                XCTAssertEqual((data as? [String: String])?["post"], "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", "Unexpected text content")
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    // MARK: - Content as JSON Request Tests

    func testGetContentAsJson() {
        guard let url = URL(string: "https://api.scryfall.com/cards/search?order=cmc&q=c%3Ared+pow%3D3") else {
            XCTFail("Invalid URL")
            return
        }

        let requestHandler = RequestHandler()
        let expectation = self.expectation(description: "Content as JSON download should succeed")

        requestHandler.GET(url: url, type: .contentAsJson) { result in
            switch result {
            case .success(let data):
                XCTAssertTrue(data is [String: Any], "Expected data to be [String: Any]")
                XCTAssertNotNil((data as? [String: Any])?["userId"], "JSON should contain 'userId' key")
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

}
