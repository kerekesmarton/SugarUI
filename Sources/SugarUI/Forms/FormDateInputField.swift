import SwiftUI
import Combine
import Sugar

public struct FormDateInputField: View {
    public init(header: String, date: Binding<Date>, isValid: Binding<Bool>) {
        self.header = header
        self._isValid = isValid
        self._date = date
    }

    let header: String
    @Binding var date: Date
    @Binding var isValid: Bool
    private var fieldPlaceholder: String? = nil

    @State private var message = ""
    private var validator: Validator<Date> = { _ in .init(isValid: true, errorMessage: "")}

    private func validate(_ date: Date) {
        let result = self.validator(date)
        isValid = result.isValid
        if isValid  {
            self.message = ""
        } else {
            self.message = result.errorMessage
        }
    }

    public var body: some View {
        Section(header: Text(header).font(Font(.title3)),
                footer:
                    Text(verbatim: message)
                    .foregroundColor(Color(.error))
                    .font(Font(.caption1))
        ) {
            DatePicker(fieldPlaceholder ?? header,
                       selection: $date.onChange {  self.validate($0) },
                       in: Date()...,
                       displayedComponents: [.hourAndMinute, .date])
        }
    }

    public func with(placeholder value: String) -> Self {
        var copy = self
        copy.fieldPlaceholder = value
        return copy
    }

    public func validator(_ block: @escaping Validator<Date> ) -> Self {
        var copy = self
        copy.validator = block
        return copy
    }
}
