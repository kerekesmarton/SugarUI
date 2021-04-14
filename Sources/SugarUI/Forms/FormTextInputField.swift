import SwiftUI
import Sugar

public struct ValidatorResult {
    public init(isValid: Bool, errorMessage: String) {
        self.isValid = isValid
        self.errorMessage = errorMessage
    }

    public var isValid: Bool
    public var errorMessage: String
}

public typealias Validator<T> = (T) -> ValidatorResult

public struct FormTextInputField: View {
    public init(header: String, field: Binding<String>, isValid: Binding<Bool>) {
        self.header = header
        self._field = field
        self._isValid = isValid
    }

    let header: String
    @Binding var field: String
    @Binding var isValid: Bool

    @State private var message: String = ""
    private var fieldPlaceholder: String? = nil
    private var onEditingChanged: (Bool) -> Void = { _ in }
    private var validator: Validator<String> = { _ in .init(isValid: true, errorMessage: "") }
    private var onCommit: Action = {}

    private func validate(value: String) {
        let result = validator(value)
        isValid = result.isValid
        if isValid {
            message = ""
        } else {
            message = result.errorMessage
        }
    }

    public var body: some View {
        Section(header: Text(header).font(Font(.title3)),
                footer:
                    Text(verbatim: message)
                    .foregroundColor(Color(.error))
                    .font(Font(.caption1))
        ) {
            TextField(fieldPlaceholder ?? header,
                      text: $field.onChange(validate(value:)),
                      onEditingChanged: { editing in onEditingChanged(editing) },
                      onCommit: onCommit)
        }
    }

    public func onChange(_ block: @escaping (Bool) -> Void) -> Self {
        var copy = self
        copy.onEditingChanged = block
        return copy
    }

    public func onCommit(_ block: @escaping Action ) -> Self {
        var copy = self
        copy.onCommit = block
        return copy
    }

    public func validator(_ block: @escaping Validator<String> ) -> Self {
        var copy = self
        copy.validator = block
        return copy
    }

    public func with(placeholder value: String) -> Self {
        var copy = self
        copy.fieldPlaceholder = value
        return copy
    }
}
