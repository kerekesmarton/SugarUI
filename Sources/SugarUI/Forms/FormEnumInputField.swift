import SwiftUI
import Sugar

public struct TransformerResult<T: RawRepresentable & Equatable> {
    var value: T
    var message: String
    var isValid: Bool
}

public typealias Transformer<T: RawRepresentable & Equatable> = (Int) -> TransformerResult<T>

public struct FormEnumInputField<T: RawRepresentable & Equatable>: View where T.RawValue == String {

    public init(header: String,
         values: [T],
         field: Binding<T>,
         isValid: Binding<Bool>,
         transformer: @escaping Transformer<T>) {
        self.header = header
        self._field = field
        self._isValid = isValid
        self.values = values
        self.transformer = transformer
    }

    let header: String
    @Binding var field: T
    @Binding var isValid: Bool
    let values: [T]
    var transformer: Transformer<T>

    private var fieldProxy: Binding<Int> {
        Binding<Int>(
            get: { values.firstIndex(of: self.field) ?? 0 },
            set: {
                let result = transformer($0)
                self.field = result.value
                self.message = result.message
                self.isValid = result.isValid
        })
    }

    @State private var message: String = ""
    private var fieldPlaceholder: String? = nil

    public var body: some View {
        Section(header: Text(header).font(Font(.title3)),
                footer:
            Text(verbatim: message)
                .foregroundColor(Color(.error))
                .font(Font(.caption1))
        ) {
            Picker(fieldPlaceholder ?? header, selection: fieldProxy) {
                ForEach(0..<values.count) { i in
                    Text(values[i].rawValue).tag(i)
                }
            }
        }
    }

    public func with(placeholder value: String) -> Self {
        var copy = self
        copy.fieldPlaceholder = value
        return copy
    }
}
