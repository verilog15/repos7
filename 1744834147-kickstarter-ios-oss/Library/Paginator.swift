import Combine
import Foundation

/**
 Used to coordinate the process of paginating through values. This class is specific to the type of pagination
 in which a page's results contains a cursor that can be used to request the next page of values.

 This class is designed to work with SwiftUI/Combine. For an example, see `PaginationExampleView.swift`.

 This class is generic over the following types:

 * `Envelope`:      The type of response we get from fetching a new page of values.
 * `Value`:         The type of value that is being paginated, i.e. a single row, not the array of rows. The
                    value must be equatable.
 * `Cursor`:        The type of value that can be extracted from `Envelope` to request the next page of
                    values.
 * `SomeError`: The type of error we might get from fetching a new page of values.
 * `RequestParams`: The type that allows us to make a request for values without a cursor.

 - parameter valuesFromEnvelope:   A function to get an array of values from the results envelope.
 - parameter cursorFromEnvelope:   A function to get the cursor for the next page from a results envelope.
 - parameter requestFromParams:    A function to get a request for values from a params value.
 - parameter requestFromCursor:    A function to get a request for values from a cursor value.

  You can observe the results of `values`, `isLoading`, `error` and `results` to access the loaded data.

 */

public class Paginator<Envelope, Value: Equatable, Cursor: Equatable, SomeError: Error, RequestParams> {
  public enum Results: Equatable {
    public static func == (
      lhs: Paginator<Envelope, Value, Cursor, SomeError, RequestParams>.Results,
      rhs: Paginator<Envelope, Value, Cursor, SomeError, RequestParams>.Results
    ) -> Bool {
      switch (lhs, rhs) {
      case (.unloaded, .unloaded):
        return true
      case let (
        .someLoaded(lhsValues, lhsCursor, lhsTotal, lhsPage),
        .someLoaded(rhsValues, rhsCursor, rhsTotal, rhsPage)
      ):
        return lhsValues == rhsValues && lhsCursor == rhsCursor && lhsTotal == rhsTotal && lhsPage == rhsPage
      case let (.allLoaded(lhsValues, lhsPage), .allLoaded(rhsValues, rhsPage)):
        return lhsValues == rhsValues && lhsPage == rhsPage
      case (.empty, .empty):
        return true
      case let (.error(lhsError), .error(rhsError)):
        return lhsError.localizedDescription == rhsError.localizedDescription
      case let (.loading(lhsPrevious), .loading(rhsPrevious)):
        return lhsPrevious == rhsPrevious
      case (.unloaded, _),
           (.someLoaded, _),
           (.allLoaded, _),
           (.empty, _),
           (.error, _),
           (.loading, _):
        return false
      }
    }

    case unloaded
    case someLoaded(values: [Value], cursor: Cursor, total: Int?, page: Int?)
    case allLoaded(values: [Value], page: Int?)
    case empty
    case error(SomeError)
    indirect case loading(previous: Results)

    public var values: [Value] {
      switch self {
      case let .loading(previous):
        previous.values
      case let .someLoaded(values, _, _, _):
        values
      case let .allLoaded(values, _):
        values
      case .unloaded, .empty, .error:
        []
      }
    }

    public var cursor: Cursor? {
      guard case let .someLoaded(_, cursor, _, _) = self else {
        return nil
      }
      return cursor
    }

    public var isLoading: Bool {
      guard case .loading = self else { return false }
      return true
    }

    public var error: SomeError? {
      guard case let .error(error) = self else { return nil }
      return error
    }

    public var canLoadMore: Bool {
      switch self {
      case .someLoaded, .unloaded:
        true
      case .empty, .error, .allLoaded, .loading:
        false
      }
    }

    public var hasLoaded: Bool {
      switch self {
      case .someLoaded, .allLoaded, .empty:
        true
      case .unloaded, .loading, .error:
        false
      }
    }

    public var total: Int? {
      switch self {
      case let .allLoaded(values, _):
        values.count
      case let .loading(previous):
        previous.total
      case let .someLoaded(_, _, total, _):
        total
      case .empty:
        0
      case .unloaded, .error:
        nil
      }
    }

    public var page: Int? {
      switch self {
      case let .allLoaded(_, page):
        page
      case let .loading(previous):
        previous.page
      case let .someLoaded(_, _, _, page):
        page
      case .empty, .unloaded, .error:
        nil
      }
    }

    /**
     Transforms the values array within the current Results state while preserving the case and other properties.

     - Parameter transform: A closure that takes an array of Values and returns a transformed array of Values
     - Returns: A new Results instance with the transformed values (if the case has values)
     */
    public func mapValues(_ transform: ([Value]) -> [Value]) -> Results {
      switch self {
      case .unloaded:
        return .unloaded
      case let .someLoaded(values, cursor, total, page):
        return .someLoaded(values: transform(values), cursor: cursor, total: total, page: page)
      case let .allLoaded(values, page):
        return .allLoaded(values: transform(values), page: page)
      case .empty:
        return .empty
      case let .error(error):
        return .error(error)
      case let .loading(previous):
        return .loading(previous: previous.mapValues(transform))
      }
    }
  }

  @Published public var results: Results

  private var valuesFromEnvelope: (Envelope) -> [Value]
  private var cursorFromEnvelope: (Envelope) -> Cursor?
  private var totalFromEnvelope: (Envelope) -> Int?
  private var requestFromParams: (RequestParams) -> AnyPublisher<Envelope, SomeError>
  private var requestFromCursor: (Cursor) -> AnyPublisher<Envelope, SomeError>
  private var cancellables = Set<AnyCancellable>()

  private var lastCursor: Cursor?

  public init(
    valuesFromEnvelope: @escaping ((Envelope) -> [Value]),
    cursorFromEnvelope: @escaping ((Envelope) -> Cursor?),
    totalFromEnvelope: @escaping ((Envelope) -> Int?),
    requestFromParams: @escaping ((RequestParams) -> AnyPublisher<Envelope, SomeError>),
    requestFromCursor: @escaping ((Cursor) -> AnyPublisher<Envelope, SomeError>)
  ) {
    self.results = .unloaded

    self.valuesFromEnvelope = valuesFromEnvelope
    self.cursorFromEnvelope = cursorFromEnvelope
    self.totalFromEnvelope = totalFromEnvelope
    self.requestFromParams = requestFromParams
    self.requestFromCursor = requestFromCursor
  }

  func handleRequest(_ request: AnyPublisher<Envelope, SomeError>, shouldClear: Bool) {
    request
      .combineLatest(self.$results.first().setFailureType(to: SomeError.self))
      .map { [weak self] envelope, previousResults -> Results in
        guard let self else {
          fatalError()
        }

        let newValues = self.valuesFromEnvelope(envelope)
        let nextCursor = self.cursorFromEnvelope(envelope)
        var allValues = shouldClear ? [] : previousResults.values
        allValues.append(contentsOf: newValues)

        let newPage: Int? = switch (previousResults.page, shouldClear, newValues.isEmpty) {
        // resetting to first page, with results should go to page 1
        case (_, true, false):
          1

        // resetting to first page, with no results, should appear empty
        case (_, true, true):
          nil

        // loading the subsequent page, with results, should increment the page
        case let (.some(page), false, false):
          page + 1

        // loading a next page when there's somehow no existing page should set the page to 1
        case (.none, false, false):
          1

        // loading a next page with no results should keep the page the same
        case let (page, false, true):
          page
        }

        let results: Results
        if allValues.count == 0 {
          results = .empty
        } else if let nextCursor, !newValues.isEmpty {
          let total = self.totalFromEnvelope(envelope)
          results = .someLoaded(values: allValues, cursor: nextCursor, total: total, page: newPage)
        } else {
          results = .allLoaded(values: allValues, page: newPage)
        }
        return results
      }
      .catch { error -> AnyPublisher<Results, Never> in
        Just(.error(error)).eraseToAnyPublisher()
      }
      .prepend(.loading(previous: self.results))
      .sink(receiveValue: { results in
        self.results = results
      })
      .store(in: &self.cancellables)
  }

  public func requestFirstPage(withParams params: RequestParams) {
    self.cancel()

    let request = self.requestFromParams(params)
    self.handleRequest(request, shouldClear: true)
  }

  public func requestNextPage() {
    guard !self.results.isLoading, let cursor = self.results.cursor else {
      return
    }

    let request = self.requestFromCursor(cursor)
    self.handleRequest(request, shouldClear: false)
  }

  public func nextResult() async -> Results {
    let publisher = AsyncPublisher(self.$results).dropFirst()
      .filter { !$0.isLoading }
    var iterator = publisher.makeAsyncIterator()
    let result = await iterator.next() ?? self.results
    return result
  }

  public func cancel() {
    if case let .loading(previous) = self.results {
      self.results = previous
    }

    self.cancellables.forEach { cancellable in
      cancellable.cancel()
    }
  }
}

extension Paginator where RequestParams == Void {
  public func requestFirstPage() {
    self.requestFirstPage(withParams: ())
  }
}
