# `DataField`

A SwiftUI view that wraps a `TextField` to only accept specific data.

---

## Motivation

SwiftUI's native `TextField` is a great tool if you want user-editable text in your app. Often it is not sufficient for a
user to enter *any* text though - it has to be text with some *specific* properties. And if the entered text doesn't
have those properties, we don't want to accept it.  
`DataField` allows you to easily and locally declare what kind of text you want to accept, and how you want to
handle invalid text.

## Installation

`DataField` can be installed via [Swift Package Manager](https://swift.org/package-manager/).

If you are using Xcode click `File > Swift Packages > Add Package Dependency` and enter the URL of
`DataField`'s repository: `https://github.com/marcusrossel/data-field.git`.

If you're a framework author and use `DataField` as a dependency, update your `Package.swift` file:

```swift
let package = Package(

    // ...

    dependencies: [
        .package(url: "https://github.com/marcusrossel/data-field.git", from: "0.1.0")
    ],

    // ...
)
```

## Usage

There are two different use cases for a `DataField`:

1. When you already have valid data, that you want to be editable by a user.
2. When you do not yet have an instance of valid data, but want to retrieve one from a user.

### Editing Preexisting Data

Let's say we wanted a user to edit the hour-component of a time value. A view for that could look something like
this:

```swift
struct HourView: View {

    @State var hour = 10

    var body: some View {
        // ...
    }
}
```

Now optimally we'd like to pass a binding to `hour` into a `TextField`, because *that* is the data we want to be
editing - but `TextField` only accepts `String` bindings. With a `DataField` though, we can pass in a binding for
any type we like. All we have to do additionally, is to specify how an instance of that type can be retrieved *from* a
`String` and how it can be converted *to* a `String`:

```swift
struct HourView: View {

    @State var hour = 10

    var body: some View {
        DataField("Hour", data: $hour) { text in
            Int(text)
        } dataToText: { data in
            "\(data)"
        }
    }
}
```

The first closure is `textToData` and the second is `dataToText`.  
In `dataToText` we specify that an `Int` should be represented as a `String` by directly converting it to one.  
In `textToData` we basically do the same in reverse. Note here that `Int(text)` returns a `String?`. Returning
`nil` in `textToData` is the way of telling the data field that the given text was not valid data. The consequence
is that, if a user tries committing such text, the data field won't write it to the binding.  
This last fact also allows us to specify constraints on the data we accept:

```swift
struct HourView: View {

    @State var hour = 10

    var body: some View {
        DataField("Hour", data: $hour) { text in
            guard let validHour = Int(text), 0..<24.contains(validHour) else { return }
            return validHour
        } dataToText: { data in
            "\(data)"
        }
    }
}
```

Here we say that we only convert given text to data if the text is convertible to an `Int` and its value is within
`0..<24`. One important constraint when creating a `DataField` is that the value of the given binding has to fulfill
the requirements specified in `textToData`. That is `textToData(dataToText(binding))` can not be `nil`! If this
condition is not satisfied, `DataField`'s initializer will return `nil`.

So how do we inform the user about invalid text? For that purpose a `DataField` can take another closure to
which it will send any invalid text:

```swift
struct HourView: View {

    @State var hour = 10
    @State var textIsInvalid = false

    var body: some View {
        VStack {
            DataField("Hour", data: $hour) { text in
                guard let validHour = Int(text), 0..<24.contains(validHour) else { return }
                return validHour
            } dataToText: { data in
                "\(data)"
            } invalidText: { text in
                textIsInvalid = (text != nil)
            }

            if textIsInvalid {
                Text("Please enter a number between 0 and 23!")
            }
        }
    }
}
```

In the example above, we simply record whether the current text is invalid in a separate state variable. We then
use that state variable's value to determine whether or not a hint should be shown below the text field. Note that
this hint will only ever show *while* the data field is being edited.

### Retrieving New Data

When using a data field, retrieving new data is somewhat different from editing preexisting data. Recall from the
section above that...

> when creating a `DataField` [...] the value of the given binding has to fulfill the requirements specified in
> `textToData`.

We can't fulfill this requirement though, if we don't even have an instance of our data, right? To fix this problem,
we can initialize a data field without passing it a binding:

```swift
struct HourView: View {

    @State var hour: Int?

    var body: some View {
        DataField("Hour") { text in
            guard let validHour = Int(text), 0..<24.contains(validHour) else { return }
            return validHour
        } dataToText: { data in
            if let data = data { return "\(data)" } else { return "" }
        } sink: { validData in
            hour = validData
        }
    }
}
```

In the example above we want to retrieve a value for `hour`, but don't have one yet. So instead of passing the data
field a binding to `hour`, we pass it a `sink` closure. This closure will receive any valid values committed to the
data field. That is, if the user ends editing with `"12"` entered, `sink` will be called with a value of `12`. If the user
ends editing with `"hello"` entered, `sink` won't be called at all.

## Safe Field

Using `sink` instead of a binding is not only suited for retrieving new values, it's generally a more safe mechanism
for data entry, since a given binding can always be overridden with invalid values from the outside. The main
downside is, that it's less convenient than just passing a binding - especially if you *know* that the value won't be
changed from the outside.  
If we consider the `HourView` from above for example, we could assume that the data comes from outside of the
view:

```swift
struct HourView: View {

    @Binding var hour: Int

    var body: some View {
        // ...
    }
}
```

In this case, it would be safest to use the following construction:

```swift
struct HourView: View {

    @Binding var hour: Int

    var body: some View {
        DataField("Hour", initialData: hour) { text in
            guard let validHour = Int(text), 0..<24.contains(validHour) else { return }
            return validHour
        } dataToText: { data in
            if let data = data { return "\(data)" } else { return "" }
        } sink: { validData in
            hour = validData
        }
    }
}
```

The `initialData` parameter allows us to pass an initial value. If the value is not valid data, it won't be shown by
the data field!

## `String`-based Fields

`DataField` has some affordances for using `String` data. Since `dataToText` and `textToData` are redundant
when working with `String` data, they can be replaced by a `constraint` closure, which returns a `Bool`
indicating whether or not a given `String` is considered *valid*:

```swift
struct NameView: View {

    @State var name = "marcus"

    var body: some View {
        VStack {
            DataField("Hour", data: $name) { text in
                !text.isEmpty
            }
        }
    }
}
```
